namespace :scheduled do

  desc 'Send daily Admin Mail'
  task daily_mail: :environment do
    AdminMailer.daily_mail.deliver_now
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

    User.confirmed.find_in_batches(batch_size: 100) do |users_batch|
      users_batch.each_with_index do |user, index|
        delay = index * 0.5.seconds
        NotificationMailer.summary_graetzl(user, user.region_id, 'daily').deliver_later(queue: 'summary-mails', wait: delay)
        NotificationMailer.summary_personal(user, user.region_id, 'daily').deliver_later(queue: 'summary-mails', wait: delay)
      end
    end
    
  end

  desc 'Send weekly summary mail'
  task weekly_summary_mail: :environment do
    puts "Rake weekly_summary_mail start at #{Time.now}"

    if Date.today.tuesday?

      User.confirmed.find_in_batches(batch_size: 100) do |users_batch|
        users_batch.each_with_index do |user, index|
          delay = index * 0.5.seconds
          NotificationMailer.summary_graetzl(user, user.region_id, 'weekly').deliver_later(queue: 'summary-mails', wait: delay)
          NotificationMailer.summary_personal(user, user.region_id, 'weekly').deliver_later(queue: 'summary-mails', wait: delay)
        end
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

    User.registered.where("email like ?", "%@imgraetzl.at%").find_each do |user|
      NotificationMailer.summary_graetzl(user, region.id, ENV['period']).deliver_now
      NotificationMailer.summary_personal(user, region.id, ENV['period']).deliver_now
    end

    Rails.logger.flush
  end

end
