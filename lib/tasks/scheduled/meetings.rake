namespace :scheduled do
  desc 'Set new startDate if in past and additional future Date exists'
  task update_meeting_date: :environment do

    # Delete all PAST Additonal Dates
    MeetingAdditionalDate.where('starts_at_date < ?', Date.today).each do |model|
      model.destroy
    end

    # Update all past meetings to next additional date.
    # Add activity only if it has been a week since the last one.
    Meeting.where("starts_at_date = ?", Date.yesterday).find_each do |meeting|
      if meeting.meeting_additional_dates.present?
        meeting.activate_next_date!
        Rails.logger.info("[Meeting] Meeting (#{meeting.id}) updated next meeting date: #{meeting.starts_at_date}")
        # Update Activity if there is none in the last week
        if !Activity.where(subject: meeting).where("created_at >= ?", 1.week.ago).exists?
          ActionProcessor.track(meeting, :create)
        end
      end
    end

    # Remove all activity from past online meetings
    Meeting.where(online_meeting: true).where("starts_at_date = ?", Date.yesterday).find_each do |meeting|
      Activity.where(subject: meeting).destroy_all
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
    user_id = nil
    Meeting.where("starts_at_date = ?", 30.days.ago).find_each do |meeting|
      next if meeting.user.initiated_meetings.upcoming.present? || user_id == meeting.user.id
      MeetingMailer.create_meeting_reminder(meeting).deliver_now
      user_id = meeting.user.id
    end
  end

end
