namespace :db do
  desc 'Housekeeping for obsolete DB records'
  task cleanup: :environment do
    puts "Rake db:cleanup start at: #{Time.now}"


    puts "Rake db:cleanup delete notifications older than 2 weeks at: #{Time.now}"
    Notification.where('created_at < ?', 2.weeks.ago).destroy_all


    puts "Rake db:cleanup delete activity older than 8 weeks at: #{Time.now}"
    Activity.where('created_at < ?', 8.weeks.ago).destroy_all


    puts "Rake db:cleanup delete activity for disabled content at: #{Time.now}"
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

    puts "Rake db:cleanup delete not paid going_tos from deleted meeting: #{Time.now}"
    GoingTo.where(meeting_id: nil).where.not(role: 2).destroy_all
  end
end
