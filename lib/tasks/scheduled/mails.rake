namespace :scheduled do
  desc 'Send out daily mail notifications'
  task daily_mail: :environment do
    puts "Rake daily_mail start at #{Time.now}"
    User.find_each do |user|
      Notification::DailyMail.new(user).deliver
    end
  end

  task summary_graetzl_mail: :environment do
    puts "Rake daily_mail start at #{Time.now}"
    User.admin.find_each do |user|
      Notification::SummaryMail.new(user, :graetzl, :daily).deliver
    end
  end

  task summary_rooms_mail: :environment do
    puts "Rake daily_mail start at #{Time.now}"
    User.admin.find_each do |user|
      Notification::SummaryMail.new(user, :rooms, :daily).deliver
    end
  end

  task summary_personal_mail: :environment do
    puts "Rake daily_mail start at #{Time.now}"
    User.admin.find_each do |user|
      Notification::SummaryMail.new(user, :personal, :daily).deliver
    end
  end

end
