class CouponService
  def initialize(users:, type:, exclude_recent_coupons: true)
    @users = users
    @type = type
    @exclude_recent_coupons = exclude_recent_coupons
    @coupon_prefix = type.to_s[0].upcase
  end

  def create_coupon_and_send
    log "all target_users: #{@users.length}"
    
    target_users = filtered_target_users

    log "filtered target_users: #{target_users.length}"

    Region.all.each do |region|
      next unless region.id == "wien" # aktuell nur Wien

      region_target_users = target_users.in(region)
      log "filtered target users in region: #{region_target_users.length}"

      next if region_target_users.empty?

      coupon = create_coupon_for(region)
      next unless coupon

      region_target_users.find_each do |user|
        CouponHistory.create!(
          user: user,
          coupon: coupon,
          sent_at: Time.current,
          valid_until: coupon.valid_until
        )

        CouponMailer.coupon_mail(user, coupon, @type).deliver_later
        log "sent to #{user.email} | #{coupon.code}"
      end

      log "coupon task finished. send coupons to #{region_target_users.length} users."
    end
  end

  def self.send_reminder_emails(days_ahead: 1)
    expiring_histories = CouponHistory
      .where(valid_until: days_ahead.days.from_now.all_day)
      .where.not(sent_at: nil)
      .where(redeemed_at: nil)
      .includes(:user, :coupon)
  
    sent_count = 0
  
    expiring_histories.each do |history|
      user = history.user
      coupon = history.coupon

      unless user && coupon
        Rails.logger.warn("[coupons_reminder_task]: skipped history ##{history.id} – user or coupon missing")
        next
      end      
  
      next unless coupon.valid?
      next if user.subscribed?
  
      CouponMailer.coupon_mail_reminder(user, coupon).deliver_later
      Rails.logger.info("[coupons_reminder_task]: sent to #{user.email} | #{coupon.code}")
      sent_count += 1
    end
  
    Rails.logger.info("[coupons_reminder_task]: Total reminders sent: #{sent_count}")
  end  

  private

  def filtered_target_users
    scope = @users.where(subscribed: false)
  
    case @exclude_recent_coupons
    when true
      excluded_ids = users_with_recent_coupons
      log "excluded due to recent coupons (any): #{excluded_ids.length}"
      scope = scope.where.not(id: excluded_ids)
    when :by_prefix
      excluded_ids = users_with_recent_coupons_with_prefix(@coupon_prefix)
      log "excluded due to recent coupons with prefix '#{@coupon_prefix}': #{excluded_ids.length}"
      scope = scope.where.not(id: excluded_ids)
    end
  
    scope
  end
  

  def users_with_recent_coupons
    User
      .joins(:coupon_histories)
      .where('coupon_histories.sent_at >= ?', 9.months.ago)
      .distinct
      .pluck(:id)
  end

  def users_with_recent_coupons_with_prefix(prefix)
    User
      .joins(coupon_histories: :coupon)
      .where('coupon_histories.sent_at >= ?', 9.months.ago)
      .where('coupons.code LIKE ?', "%-#{prefix}%")
      .distinct
      .pluck(:id)
  end

  def log(msg)
    Rails.logger.info("[coupons_task_#{@type}]: #{msg}")
  end

  def create_coupon_for(region)
    abo_short_name = "JUHU"
    product_ids = SubscriptionPlan.in(region)
      .enabled
      .where("UPPER(short_name) LIKE ?", "%#{abo_short_name}%")
      .pluck(:stripe_product_id)

    return nil if product_ids.empty?

    coupon_code = generate_coupon_code(abo_short_name)

    stripe_coupon = Stripe::Coupon.create(
      id: coupon_code,
      amount_off: (15.00 * 100).to_i,
      currency: 'eur',
      duration: 'repeating',
      duration_in_months: 240,
      name: "15 € Rabatt auf #{abo_short_name}",
      redeem_by: 7.days.from_now.end_of_day.to_i,
      applies_to: { products: product_ids }
    )

    Coupon.create!(
      code: coupon_code,
      stripe_id: stripe_coupon.id,
      amount_off: 15.00,
      percent_off: nil,
      duration: stripe_coupon.duration,
      name: stripe_coupon.name,
      enabled: true,
      valid_from: Time.current,
      valid_until: Time.at(stripe_coupon.redeem_by),
      region_id: region.id,
      description: "created via #{@type} coupons task"
    )
  rescue Stripe::StripeError => e
    log "Fehler beim Erstellen des Gutscheins in Stripe: #{e.message}"
    nil
  end

  def generate_coupon_code(prefix)
    random_part = "#{rand(1000)}#{SecureRandom.hex(1).upcase}"  # z. B. "826C"
    "#{prefix}-#{Time.current.strftime('%d%m%y')}-#{@coupon_prefix}#{random_part}"
  end
  
end
