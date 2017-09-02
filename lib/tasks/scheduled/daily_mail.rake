namespace :scheduled do
  desc 'Send out daily mail notifications'
  task daily_mail: :environment do
    puts "Rake daily_mail start at #{Time.now}"
    SendDigestNotificationsJob.new.perform
  end
end
