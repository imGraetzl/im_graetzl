namespace :scheduled do

  desc "Coupon Task for Meeting Users"
  task coupons_task_meeting: :environment do
    next unless Date.today.friday?

    meeting_start_date = 3.weeks.ago.beginning_of_week
    meeting_created_at_date = 3.months.ago.beginning_of_month
    minimum_registration_date = 6.months.ago

    target_users = User
      .confirmed
      .joins(:initiated_meetings)
      .where('users.created_at <= ?', minimum_registration_date)
      .group(:id)
      .having('COUNT(CASE WHEN meetings.starts_at_date >= ? AND meetings.created_at >= ? THEN 1 ELSE NULL END) >= 1', meeting_start_date, meeting_created_at_date)
      .having('COUNT(meetings.id) >= 10')

    CouponService.new(users: target_users, type: :meeting).create_coupon_and_send
  end

  desc "Coupon Task for Location Users"
  task coupons_task_location: :environment do
    next unless Date.today.friday?

    minimum_registration_date = 6.months.ago
    minimum_sign_in_count = 15
    max_last_login_date = 1.months.ago

    target_users = User
      .confirmed
      .joins(:locations)
      .where('users.created_at <= ?', minimum_registration_date)
      .where('sign_in_count >= ?', minimum_sign_in_count)
      .where(
        '(users.current_sign_in_at >= ? OR users.last_sign_in_at >= ?)', 
        max_last_login_date, max_last_login_date
      )
      .where(locations: { state: Location.states[:approved] })
      .where('users.weekly_mail_notifications & ? > 0', 2**0) # User bekommt wöchentliche Mails (meetings)
      .distinct
      .left_joins(:room_offers, :room_demands)
      .where(
        'room_offers.id IS NULL OR room_offers.status != ?', RoomOffer.statuses[:enabled]
      )
      .where(
        'room_demands.id IS NULL OR room_demands.status != ?', RoomDemand.statuses[:enabled]
      )

    CouponService.new(users: target_users, type: :location).create_coupon_and_send
  end

  desc "Coupon Task for Good Morning Dates"
  task coupons_task_gmd: :environment do
    # Step 1: GoingTos von heute + Good Morning Dates mit aktivem Meeting
    going_tos = GoingTo
      .includes(:user, :meeting)
      .where(going_to_date: Date.today)
      .select { |gt| gt.meeting&.good_morning_date? && gt.meeting.active? }

    # Step 2: Alle zugehörigen User IDs ohne Duplikate
    user_ids = going_tos.map(&:user_id).uniq
    target_users = User.where(id: user_ids)

    # Step 3: GMD-Coupon nur für die Nutzer senden
    CouponService.new(users: target_users, type: :gmd, exclude_recent_coupons: :by_prefix).create_coupon_and_send
  end

  desc "Coupon Reminder Task"
  task coupons_reminder_task: :environment do    
    CouponService.send_reminder_emails(days_ahead: 1)
  end
end
