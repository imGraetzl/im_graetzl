namespace :db do
  desc 'Housekeeping for obsolete DB records'
  task truncate: :environment do
    Rails.logger.info 'Run DB Truncate Housekeeping Task'
    if ENV['ALLOW_WORKER'] == 'true'
      Rails.logger.info 'Delete Notifications older than 2 weeks'
      Notification.where('created_at < ?', 2.weeks.ago).destroy_all
      Rails.logger.info 'Delete Activity older than 6 weeks'
      PublicActivity::Activity.where('created_at < ?', 6.weeks.ago).destroy_all
    else
      Rails.logger.info 'Not in Worker ENV'
    end
  end
end
