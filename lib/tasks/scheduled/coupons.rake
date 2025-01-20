namespace :scheduled do

  desc "Erstelle und verschicke Gutscheincodes für die Zielgruppe"
  task coupons_task: :environment do

    # return unless Date.today.saturday?

    # ------------------------ TARGET USERS

    # Definiere den Zeitraum für Meetings
    meeting_start_date = 3.weeks.ago.beginning_of_week
    meeting_created_at_date = 3.months.ago.beginning_of_month

    # Definiere das Mindest-Registrierungsdatum der User
    minimum_registration_date = 6.months.ago

    # Finde User mit Coupon-History innerhalb der letzten 6 Monate
    excluded_users_with_recent_coupons = User
      .joins(:coupon_histories)
      .where('coupon_histories.sent_at >= ?', 6.months.ago)
      .distinct

    # Aktive User mit den Bedingungen
    #all_target_users = User.confirmed.where("email LIKE ?", "%michael.walchhuetter%")
    all_target_users = User
      .confirmed
      .joins(:initiated_meetings)
      .where(subscribed: false)
      .where('users.created_at <= ?', minimum_registration_date)
      .group(:id)
      .having('COUNT(CASE WHEN meetings.starts_at_date >= ? AND meetings.created_at >= ? THEN 1 ELSE NULL END) >= 1', meeting_start_date, meeting_created_at_date)
      .having('COUNT(meetings.id) >= 10')

    # Filtere die User, um nur die zu behalten, die keine Coupons in den letzten 6 Monaten haben
    target_users = all_target_users.where.not(id: excluded_users_with_recent_coupons.pluck(:id))

    Rails.logger.info("[coupons task]: all_target_users: #{all_target_users.length}")
    Rails.logger.info("[coupons task]: excluded_users_with_recent_coupons: #{excluded_users_with_recent_coupons.count}")
    Rails.logger.info("[coupons task]: target_users: #{target_users.length}")

    # ------------------------ SEND LOGIC

    Region.all.each do |region|
      next unless region.id == "wien" # only wien for now

      region_target_users = target_users.in(region)
      Rails.logger.info("[coupons task]: region_target_users: #{region_target_users.length}")

      next if region_target_users.empty?

      # Get stripe_product_ids as array (z.b. juhu abos, oder alle ...)
      abo_short_name = "JUHU"
      product_ids = SubscriptionPlan.in(region)
                      .enabled
                      .where("UPPER(short_name) LIKE ?", "%#{abo_short_name}%")
                      .pluck(:stripe_product_id)

      next if product_ids.empty?

      # Gutschein erstellen
      coupon_code = "#{abo_short_name}-#{Time.current.strftime('%d%m%y')}-#{SecureRandom.hex(3).upcase}"

      begin
        stripe_coupon = Stripe::Coupon.create(
          id: coupon_code,
          amount_off: (15.00 * 100).to_i,     # Betrag in Cent umrechnen (15 € → 1000 Cent)
          currency: 'eur',                    # Währung: Euro
          duration: 'forever',                # Erste Rechnung oder immer (once / forever)
          name: "15 € Rabatt auf #{abo_short_name}",  # Name des Coupons
          redeem_by: 7.days.from_now.end_of_day.to_i, # Gültig bis 1 Woche ab jetzt
          applies_to: {                       # Optional: Beschränkung auf Produkte
            products: product_ids             # Ersetze mit der Stripe-Produkt-ID
          }
        )

        # Gutschein in der lokalen DB speichern
        coupon = Coupon.create!(
          code: coupon_code,
          stripe_id: stripe_coupon.id,
          amount_off: 15.00,               # Betrag in Euro (Schema berücksichtigt decimal)
          percent_off: nil,                # Kein Prozent-Rabatt
          duration: stripe_coupon.duration,
          name: stripe_coupon.name,
          enabled: true,
          valid_from: Time.current,
          valid_until: Time.at(stripe_coupon.redeem_by),
          region_id: region.id
        )

      rescue Stripe::StripeError => e
        Rails.logger.info("[coupons task]: Fehler beim Erstellen des Gutscheins in Stripe: #{e.message}")
        return
      end

      Rails.logger.info("[coupons task]: Coupon erstellt: ID: #{coupon.id} | Code: #{coupon_code}")

      # Zielgruppe iterieren und CouponHistory erstellen und versenden
      region_target_users.find_each do |user|
        CouponHistory.create!(
          user: user,
          coupon: coupon,
          sent_at: Time.current,
          valid_until: coupon.valid_until
        )

        # E-Mail an Nutzer verschicken
        CouponMailer.coupon_mail(user, coupon).deliver_later
      end

      Rails.logger.info("[coupons task]: Gutscheinaktion abgeschlossen. #{region_target_users.length} Nutzer beschickt.")

    end

  end
end
