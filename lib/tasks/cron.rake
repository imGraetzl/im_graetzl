namespace :cron do
  desc 'send daily notifications to user'
  task send_daily_notifications: :environment do
    User.where("daily_mail_notifications > 0").each do |u|
      #SendMailNotificationJob.perform_later(u.id, 'daily')
    end
  end

  desc 'send weekly notifications to user'
  task send_weekly_notifications: :environment do
    User.where("weekly_mail_notifications > 0").each do |u|
      #SendMailNotificationJob.perform_later(u.id, 'weekly')
    end
  end
end
