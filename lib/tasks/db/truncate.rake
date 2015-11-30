namespace :db do
  desc 'Housekeeping for obsolete DB records'
  task truncate: :environment do
    puts 'Run DB Truncate Housekeeping Task'
    puts 'Delete Notifications older than 2 weeks'
    Notification.where('created_at < ?', 2.weeks.ago).destroy_all
    puts 'Delete Activity older than 6 weeks'
    PublicActivity::Activity.where('created_at < ?', 6.weeks.ago).destroy_all
  end
end
