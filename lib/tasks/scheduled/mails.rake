namespace :scheduled do

  desc 'Send daily Admin Mail'
  task daily_mail: :environment do
    AdminMailer.daily_mail.deliver_later
  end

  desc 'Send messenger notifications'
  task unseen_messages: :environment do
    time_range = 1.day.ago..10.minutes.ago
    UserMessageThread.includes(user_messages: :user, user_message_thread_members: :user).where(last_message_at: time_range).find_each do |thread|
      thread.user_message_thread_members.each do |user_thread|
        unseen_messages = thread.user_messages.select{ |m| m.id > user_thread.last_message_seen_id }
        next if unseen_messages.empty?
        p "#{user_thread.user.email} #{unseen_messages.count} unseen messages."
        MessengerMailer.unseen_messages(user_thread.user, unseen_messages.reverse).deliver_now
        user_thread.update(last_message_seen_id: unseen_messages.map(&:id).max)
      end
    end
  end

  desc 'Send daily summary mail'
  task daily_summary_mail: :environment do
    puts "Rake daily_summary_mail start at #{Time.now}"
    User.confirmed.find_each do |user|
      Region.all.each do |region|
        NotificationMailer.summary_graetzl(user, region, 'daily').deliver_now
        NotificationMailer.summary_personal(user, region, 'daily').deliver_now
      end
    end
  end

  desc 'Send weekly summary mail'
  task weekly_summary_mail: :environment do
    puts "Rake weekly_summary_mail start at #{Time.now}"

    User.confirmed.find_each do |user|
      NotificationMailer.summary_graetzl(user, user.region, 'weekly').deliver_now if Date.today.tuesday?
      NotificationMailer.summary_personal(user, user.region, 'weekly').deliver_now if Date.today.tuesday?
      #Region.all.each do |region|
      #  NotificationMailer.summary_graetzl(user, region, 'weekly').deliver_now if Date.today.tuesday?
      #  NotificationMailer.summary_personal(user, region, 'weekly').deliver_now if Date.today.tuesday?
      #end
    end
  end

  desc 'Send pending immediate mails'
  task pending_immediate_mails: :environment do
    puts "Rake pending_immediate_mails start at #{Time.now}"

    Notification.where(type: 'Notifications::NewMeeting').where('notify_at = ?', Date.today).where(sent: false).each do |notification|
      if notification.user.enabled_mail_notification?(notification, :immediate)
        NotificationMailer.send_immediate(notification).deliver_later
      end
    end
  end

  task test_summary_mail: :environment do
    #user = User.find_by(email: "michael.walchhuetter@gmail.com")

    region = Region.get(ENV['region'])
    if region.nil?
      print "Please select region by using:\n\nrake scheduled:test_summary_mail region=wien\n\n"
      print "Available regions: #{Region.all.map(&:id).join(", ")}\n"
      exit
    end

    if ENV['period'].nil?
      print "Please select period by using:\n\nrake scheduled:test_summary_mail period=daily\n\n"
      print "Available periods: daily, weekly\n"
      exit
    end

    User.where("email like ?", "%@imgraetzl.at%").find_each do |user|
      NotificationMailer.summary_graetzl(user, region, ENV['period']).deliver_now
      NotificationMailer.summary_personal(user, region, ENV['period']).deliver_now
    end

    Rails.logger.flush
  end

end
