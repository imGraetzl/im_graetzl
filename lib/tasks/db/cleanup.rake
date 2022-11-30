namespace :db do
  desc 'Housekeeping for obsolete DB records'
  task cleanup: :environment do
    puts "Rake db:cleanup start at: #{Time.now}"

    # Delete Expired and already sent Notifications
    Notification.where('notify_at < ?', 15.days.ago).where("notify_before IS NULL OR notify_before < ?", Time.current).destroy_all
    Notification.where('notify_at < ?', 15.days.ago).where(sent: true).destroy_all

    # Delete WeLocally Activities after 6 Months and Vienna Activities after 4 Months
    Activity.where('created_at < ?', 12.months.ago).destroy_all
    Activity.where('region_id = ?', 'wien').where('created_at < ?', 4.months.ago).destroy_all

    Activity.where(subject_type: 'Meeting').find_each do |activity|
      if activity.subject.ends_at_date
        activity.destroy if activity.subject.ends_at_date < Date.yesterday
      else
        activity.destroy if activity.subject.starts_at_date < Date.yesterday
      end
    end

    # Delete going_tos from deleted meeting
    GoingTo.where(meeting_id: nil).destroy_all

    # Delete Meetings without User - Todo: Add to UserModel
    Meeting.where(user_id: nil).destroy_all

    # Delete empty UserMessageThreads
    UserMessageThread.where(thread_type: 'general').where(last_message: nil).destroy_all

  end
end
