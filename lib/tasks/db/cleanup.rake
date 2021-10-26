namespace :db do
  desc 'Housekeeping for obsolete DB records'
  task cleanup: :environment do
    puts "Rake db:cleanup start at: #{Time.now}"

    Notification.where('created_at < ?', 2.weeks.ago).destroy_all
    Activity.where('created_at < ?', 8.weeks.ago).destroy_all

    RoomOffer.where(status: :disabled).find_each do |room_offer|
      Activity.where(subject: room_offer).destroy_all
      Notification.where(subject: room_offer).destroy_all
    end
    RoomDemand.where(status: :disabled).find_each do |room_demand|
      Activity.where(subject: room_demand).destroy_all
      Notification.where(subject: room_demand).destroy_all
    end
    CoopDemand.where(status: :disabled).find_each do |coop_demand|
      Activity.where(subject: coop_demand).destroy_all
      Notification.where(subject: coop_demand).destroy_all
    end
    ToolOffer.where(status: :disabled).find_each do |tool_offer|
      Activity.where(subject: tool_offer).destroy_all
      Notification.where(subject: tool_offer).destroy_all
    end
    ToolDemand.where(status: :disabled).find_each do |tool_demand|
      Activity.where(subject: tool_demand).destroy_all
      Notification.where(subject: tool_demand).destroy_all
    end

    # Delete not paid going_tos from deleted meeting
    GoingTo.where(meeting_id: nil).where.not(role: 2).destroy_all

    # Delete Meetings without User - Todo: Add to UserModel
    Meeting.where(user_id: nil).destroy_all

  end
end
