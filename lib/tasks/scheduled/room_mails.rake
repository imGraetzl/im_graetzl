namespace :scheduled do

  desc 'Room Info Mail'
  task room_info_mail: :environment do

    RoomOffer.where("DATE(created_at) = ?", Date.today - 5).find_each do |room_offer|
      next if room_offer.user.nil?
      RoomMailer.room_offer_info_mail(room_offer).deliver_later
    end

    RoomDemand.where("DATE(created_at) = ?", Date.today - 5).find_each do |room_demand|
      next if room_demand.user.nil?
      RoomMailer.room_demand_info_mail(room_demand).deliver_later
    end

  end

  desc 'Reminder for Room expiring'
  task reminder_room_expiring: :environment do

    room_offer_lifetime_months = RoomOffer::LIFETIME_MONTHS
    # Disable expiring RoomOffers and send reminder mail for activating
    # Only send mail if valid -> status can be updated via link
    RoomOffer.enabled.where("last_activated_at < ?", room_offer_lifetime_months.months.ago).find_each do |room_offer|
      room_offer.update_attribute(:status, "disabled")
      room_offer.destroy_activity_and_notifications
      RoomMailer.room_offer_activate_reminder(room_offer).deliver_later if room_offer.valid?
    end

    room_demand_lifetime_months = RoomDemand::LIFETIME_MONTHS
    # Disable expiring RoomDemands and send reminder mail for activating
    # Only send mail if valid -> status can be updated via link
    RoomDemand.enabled.where("last_activated_at < ?", room_demand_lifetime_months.months.ago).find_each do |room_demand|
      room_demand.update_attribute(:status, "disabled")
      room_demand.destroy_activity_and_notifications
      RoomMailer.room_demand_activate_reminder(room_demand).deliver_later if room_demand.valid?
    end

  end
end
