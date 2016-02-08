desc 'Send out daily mail notifications'
task daily_mail: :environment do
  puts 'Run daily_mail task'
  SendDigestNotificationsJob.new().perform
end
