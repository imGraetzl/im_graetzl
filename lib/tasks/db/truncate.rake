namespace :db do
  desc 'Housekeeping for obsolete DB records'
  task truncate: :environment do
    puts "Rake db:truncate start at: #{Time.now}"
    puts "Rake db:truncate delete notifications older than 2 weeks at: #{Time.now}"
    Notification.where('created_at < ?', 2.weeks.ago).destroy_all
    puts "Rake db:truncate delete activity older than 6 weeks at: #{Time.now}"
    Activity.where('created_at < ?', 6.weeks.ago).destroy_all
  end
end
