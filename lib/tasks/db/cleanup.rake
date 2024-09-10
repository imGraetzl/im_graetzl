namespace :db do
  desc 'Housekeeping for obsolete DB records'
  task cleanup: :environment do
    puts "Rake db:cleanup start at: #{Time.now}"

    task_starts_at = Time.now
    #AdminMailer.task_info('db:cleanup', 'started', task_starts_at).deliver_now

    # Delete unconfirmed OLD Users (older 3 months)
    User.where(confirmed_at:nil).where('created_at < ?', 3.months.ago).delete_all

    # Delete incomplete OLD Items
    Zuckerl.incomplete.where('created_at < ?', 2.weeks.ago).where(payment_status:nil).destroy_all
    CrowdBoostCharge.general.incomplete.where('created_at < ?', 2.weeks.ago).destroy_all

    # Delete Expired and already sent Notifications
    # 1.) Delete all SENT Notifications which are not used for Web
    # 2.) Delete all OLD Notifications which are not used for Web after 1 week
    # 3.) Delete all OLD Notifications (also Web) after 2 weeks
    Notification.where(sent: true, display_on_website: false).delete_all
    Notification.where('notify_at < ?', 7.days.ago).where("notify_before IS NULL OR notify_before < ?", Time.current).where(display_on_website: false).delete_all
    Notification.where('notify_at < ?', 14.days.ago).delete_all


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

    
    # Delete going_tos from deleted meeting
    GoingTo.where(meeting_id: nil).destroy_all

    # Delete empty UserMessageThreads
    UserMessageThread.where(thread_type: 'general').where(last_message: nil).destroy_all

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
    AdminMailer.task_info('db:cleanup', 'finished', task_starts_at, task_ends_at).deliver_now

  end
end
