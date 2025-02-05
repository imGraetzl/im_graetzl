namespace :scheduled do

  # Create and Send Coupons Method
  def send_coupons(users, type)

    # Exclude Users already got a Coupon during the last 6 months
    excluded_users_with_recent_coupons = User
      .joins(:coupon_histories)
      .where('coupon_histories.sent_at >= ?', 6.months.ago)
      .distinct

    target_users = users.where.not(id: excluded_users_with_recent_coupons.pluck(:id))
    Rails.logger.info("[coupons_task_#{type}]: cleaned target_users: #{target_users.length}")
    # puts "[coupons_task_#{type}]: cleaned target_users: #{target_users.length}"

    Region.all.each do |region|
      
      next unless region.id == "wien" # only wien for now

      region_target_users = target_users.in(region)
      Rails.logger.info("[coupons_task_#{type}]: region_target_users: #{region_target_users.length}")
      # puts "[coupons_task_#{type}]: region_target_users: #{region_target_users.length}"

      next if region_target_users.empty?

      # Get stripe_product_ids as array (z.b. juhu abos, oder alle ...)
      abo_short_name = "JUHU"
      product_ids = SubscriptionPlan.in(region)
                      .enabled
                      .where("UPPER(short_name) LIKE ?", "%#{abo_short_name}%")
                      .pluck(:stripe_product_id)

      next if product_ids.empty?

      # Coupon erstellen
      coupon_prefix = "#{type.to_s[0].upcase}#{rand(10)}"
      coupon_code = "#{abo_short_name}-#{Time.current.strftime('%d%m%y')}-#{coupon_prefix}#{SecureRandom.hex(2).upcase}"

      begin
        stripe_coupon = Stripe::Coupon.create(
          id: coupon_code,
          amount_off: (15.00 * 100).to_i,
          currency: 'eur',
          duration: 'forever',
          name: "15 € Rabatt auf #{abo_short_name}",
          redeem_by: 7.days.from_now.end_of_day.to_i,
          applies_to: {
            products: product_ids
          }
        )

        # Coupon in der lokalen DB speichern
        coupon = Coupon.create!(
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
          description: "created via #{type} coupons task"
        )

      rescue Stripe::StripeError => e
        Rails.logger.info("[coupons task]: Fehler beim Erstellen des Gutscheins in Stripe: #{e.message}")
        return
      end

      Rails.logger.info("[coupons_task_#{type}]: Coupon erstellt: ID: #{coupon.id} | Code: #{coupon_code}")
      # puts "[coupons_task_#{type}]: Coupon erstellt: ID: #{coupon.id} | Code: #{coupon_code}"

      # Zielgruppe iterieren und CouponHistory erstellen und versenden
      region_target_users.find_each do |user|
        CouponHistory.create!(
          user: user,
          coupon: coupon,
          sent_at: Time.current,
          valid_until: coupon.valid_until
        )

        # E-Mail an Nutzer verschicken
        CouponMailer.coupon_mail(user, coupon, type).deliver_later
        Rails.logger.info("[coupons_task_#{type}]: sent to #{user.email} | #{coupon.code}")
        # puts "[coupons_task_#{type}]: sent to #{user.email} | #{coupon.code}"
      end

      Rails.logger.info("[coupons_task_#{type}]: Gutscheinaktion abgeschlossen. #{region_target_users.length} Nutzer beschickt.")

    end
  end

  desc "Coupon Task for Meeting Users"
  task coupons_task_meeting: :environment do

    next unless Date.today.friday?

    meeting_start_date = 3.weeks.ago.beginning_of_week
    meeting_created_at_date = 3.months.ago.beginning_of_month
    minimum_registration_date = 6.months.ago

    target_users = User
      .confirmed
      .joins(:initiated_meetings)
      .where(subscribed: false)
      .where('users.created_at <= ?', minimum_registration_date)
      .group(:id)
      .having('COUNT(CASE WHEN meetings.starts_at_date >= ? AND meetings.created_at >= ? THEN 1 ELSE NULL END) >= 1', meeting_start_date, meeting_created_at_date)
      .having('COUNT(meetings.id) >= 10')

    # target_users = User.confirmed.where("email LIKE ?", "%michael.walchhuetter%")
    # puts "[coupons_task_meeting]: all target_users: #{target_users.length}"
    Rails.logger.info("[coupons_task_meeting]: all target_users: #{target_users.length}")
    send_coupons(target_users, :meeting)

  end



  desc "Coupon Task for Location Users"
  task coupons_task_location: :environment do

    next unless Date.today.friday?

    minimum_registration_date = 6.months.ago
    minimum_sign_in_count = 10
    max_last_login_date = 1.months.ago

    target_users = User
      .confirmed
      .joins(:locations)
      .where(subscribed: false)
      .where('users.created_at <= ?', minimum_registration_date)
      .where('sign_in_count >= ?', minimum_sign_in_count)
      .where(
        '(users.current_sign_in_at >= ? OR users.last_sign_in_at >= ?)', 
        max_last_login_date, max_last_login_date
      )
      .where(locations: { state: Location.states[:approved] })
      .where('users.weekly_mail_notifications & ? > 0', 2**0) # User bekommt wöchentliche Mails (meetings)
      .distinct

    # target_users = User.confirmed.where("email LIKE ?", "%michael.walchhuetter%")
    # puts "[coupons_task_location]: all target_users: #{target_users.length}"
    Rails.logger.info("[coupons_task_location]: all target_users: #{target_users.length}")
    send_coupons(target_users, :location)

  end



  desc 'Coupon Reminder Mail'
  task coupons_reminder_task: :environment do
    # Suche alle CouponHistories mit valid_until in 1 Tagen, sent_at gesetzt und redeemed_at leer (noch nicht eingelöst)
    expiring_coupons = CouponHistory
      .where(valid_until: 1.days.from_now.all_day)
      .where.not(sent_at: nil)
      .where(redeemed_at: nil)

    sent_count = 0

    expiring_coupons.each do |history|
      user = history.user
      coupon = history.coupon

      # Nur gültige Coupons berücksichtigen
      next unless coupon.valid?

      # Nutzer überspringen, wenn bereits Abo vorhanden
      next if user.subscribed?

      # Reminder-E-Mail senden
      CouponMailer.coupon_mail_reminder(user, coupon).deliver_later
      sent_count += 1

      Rails.logger.info("[coupons_reminder_task]: sent to #{user.email} | #{coupon.code}")
    end

    Rails.logger.info("[coupons_reminder_task]: Total reminders sent: #{sent_count}")
  end

end
