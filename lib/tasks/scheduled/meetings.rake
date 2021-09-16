namespace :scheduled do
  desc 'Set new startDate if in past and additional future Date exists'
  task update_meeting_date: :environment do

    # Delete all PAST Additonal Dates
    MeetingAdditionalDate.where('starts_at_date < ?', Date.today).each do |model|
      model.destroy
    end

    # Find all Meetings where Start Date = Yesterday
    # Look if they have Additonal Dates in Future
    # Set new startDate for Meeting
    # Delete next Additonal Date
    # Update Activity if previous Activity of this Meeting is more then 1 Week ago
    Meeting.where("starts_at_date = ?", Date.yesterday).find_each do |meeting|
      if meeting.meeting_additional_dates.present?

        next_meeting = meeting.meeting_additional_dates.sort_by(&:starts_at_date).first
        meeting.update(starts_at_date: next_meeting.starts_at_date, starts_at_time: next_meeting.starts_at_time, ends_at_time: next_meeting.ends_at_time)
        next_meeting.destroy
        Rails.logger.info("[Meeting] Meeting (#{meeting.id}) updated next meeting date: #{next_meeting.starts_at_date}")
        # Update Activity for this Meeting if last Activity is greather then 1 week ago or if there is no Activity - And delete old online Activities
        if !meeting.activities.where(key: 'meeting.create').present? || meeting.activities.where(key: 'meeting.create').last.created_at < 6.days.ago
          meeting.activities.where(key: 'meeting.create').destroy_all
          meeting.create_activity :create, owner: meeting.user, cross_platform: meeting.online_meeting?
        end

      else

        # Destroy old "create.meeting" Activities for online meetings if no Additonal Dates present (lets stay offline meetings for now)
        meeting.activities.where(key: 'meeting.create').destroy_all if meeting.online_meeting?

      end

    end

  end

  desc 'Send Meeting Create Reminder Mail to Past Meeting Owners'
  task info_mail_create_meeting_reminder: :environment do
    user_id = nil
    Meeting.upcoming.includes(:event_categories).where(event_categories: {id: nil}).find_each do |meeting|
      next if user_id == meeting.user.id
      MeetingMailer.missing_meeting_category(meeting).deliver_now
      user_id = meeting.user.id
    end
  end

  desc 'Send Create Meeting Reminder'
  task create_meeting_reminder_mail: :environment do
    puts "----------------TASK STARTED"
    user_id = nil
    Meeting.where("starts_at_date = ?", 1.day.ago).find_each do |meeting|
      puts "----------------meeting : #{meeting}"
      next if meeting.user.initiated_meetings.upcoming.present? || user_id == meeting.user.id
      MeetingMailer.create_meeting_reminder(meeting).deliver_now
      puts "----------------send mail to meeting : #{meeting}"
      user_id = meeting.user.id
    end
  end

end
