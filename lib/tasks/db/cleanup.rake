namespace :db do
  desc 'Housekeeping for obsolete DB records'
  task cleanup: :environment do
    puts "Rake db:cleanup start at: #{Time.now}"

    task_starts_at = Time.now

    # Delete unconfirmed OLD Users (older 1 month)
    User.registered.where(confirmed_at: nil).where('created_at < ?', 1.month.ago).delete_all

    # Delete incomplete OLD Items
    Zuckerl.incomplete.where('created_at < ?', 1.week.ago).where(payment_status: nil).destroy_all
    CrowdBoostCharge.general.incomplete.where('created_at < ?', 1.week.ago).destroy_all
    CrowdPledge.incomplete.where(inclomplete_reminder_sent_at: nil).where('created_at < ?', 6.months.ago).destroy_all

    # Delete Expired and already sent Notifications
    # 1.) Delete all SENT Notifications which are not used for Web
    # 2.) Delete all OLD Notifications which are not used for Web after 1 week
    # 3.) Delete all OLD Notifications (also Web) after 2 weeks
    Notification.where(sent: true, display_on_website: false).delete_all
    Notification.where('notify_at < ?', 7.days.ago).where("notify_before IS NULL OR notify_before < ?", Date.today).where(display_on_website: false).delete_all
    Notification.where(type: 'Notifications::NewMeeting').where('notify_before < ?', Date.today).delete_all
    Notification.where('notify_at < ?', 14.days.ago).delete_all

    # Delete unused Notifications of Users which has turned OFF
    # Todo: Try to avoid creating Notifications for these Users
    [:NewMeeting, :NewRoomOffer].each do |type|
      User.user_mail_setting_eq("off_#{type}").find_each do |user|
        user.notifications.where(type: "Notifications::#{type}").delete_all
      end
    end

    # Delete WeLocally Activities after 12 Months and imGraetzl Activities after 6 Months
    Activity.where('created_at < ?', 12.months.ago).destroy_all
    Activity.where('region_id = ?', 'wien').where('created_at < ?', 6.months.ago).destroy_all

    # Delete expired Meeting Activities
    Activity.where(subject_type: 'Meeting').find_each do |activity|
      if activity.subject.ends_at_date
        activity.destroy if activity.subject.ends_at_date < Date.today
      else
        activity.destroy if activity.subject.starts_at_date < Date.today
      end
    end

    # Delete empty UserMessageThreads
    UserMessageThread.where(thread_type: 'general').where(last_message: nil).destroy_all

    # Delete empty Favorites (sometimes dependent destroy doesnt have effect...)
    Favorite.find_each do |favorite|
      favorite.destroy if favorite.favoritable.nil?
    end

    # Delete empty Activities (sometimes dependent destroy doesnt have effect...)
    Activity.find_each do |activity|
      activity.destroy if activity.subject.nil?
    end

    # Reset & Update all Counter Caches to keep in Sync

    Group.find_each do |group|
      Group.reset_counters(group.id, :group_users)
    end

    PollOption.find_each do |option|
      PollOption.reset_counters(option.id, :poll_user_answers)
    end

    PollQuestion.find_each do |question|
      PollQuestion.reset_counters(question.id, :poll_user_answers)
    end

    task_ends_at = Time.now
    #AdminMailer.task_info('db:cleanup', 'finished', task_starts_at, task_ends_at).deliver_now

  end
end
