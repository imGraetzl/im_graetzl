namespace :db do
  desc 'Housekeeping for obsolete DB records'
  task cleanup: :environment do
    puts "Rake db:cleanup start at: #{Time.now}"

    # Delete Expired and already sent Notifications
    Notification.where('notify_at < ?', 10.days.ago).where("notify_before IS NULL OR notify_before < ?", Time.current).destroy_all
    Notification.where('notify_at < ?', 10.days.ago).where(sent: true).destroy_all

    # Delete WeLocally Activities after 12 Months and Vienna Activities after 6 Months
    Activity.where('created_at < ?', 12.months.ago).destroy_all
    Activity.where('region_id = ?', 'wien').where('created_at < ?', 6.months.ago).destroy_all

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

  end
end
