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

        # Update Activity if there is none in the last week or 2 weeks for online meetings
        if meeting.online_meeting? && !Activity.where(subject: meeting).where("created_at >= ?", 2.weeks.ago).exists?
          ActionProcessor.track(meeting, :update)
        elsif !meeting.online_meeting? && !Activity.where(subject: meeting).where("created_at >= ?", 1.week.ago).exists?
          ActionProcessor.track(meeting, :update)
        end

      end
    end

    # Remove all activity from past online meetings
    Meeting.where(online_meeting: true).where("starts_at_date = ?", Date.yesterday).find_each do |meeting|
      Activity.where(subject: meeting).destroy_all
    end
  end

  desc 'Send Create Meeting Reminder'
  task create_meeting_reminder_mail: :environment do
    already_sent = []
    Meeting.where(starts_at_date: 30.days.ago).find_each do |meeting|
      next if meeting.user.nil? || meeting.user.initiated_meetings.where("starts_at_date > ?", 30.days.ago).present? || already_sent.include?(meeting.user.id)
      MeetingMailer.create_meeting_reminder(meeting).deliver_now
      already_sent.push(meeting.user.id)
    end
  end

end
