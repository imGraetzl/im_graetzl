namespace :scheduled do
  desc 'Reminder for Room expiring'
  task reminder_room_expiring: :environment do

    # Disable expiring Rooms and send reminder mail for activating
    RoomOffer.enabled.where("last_activated_at < ?", 6.months.ago).find_each do |room_offer|
      room_offer.update(status: "disabled")
      RoomMailer.room_offer_activate_reminder(room_offer).deliver_later
    end

  end
end
