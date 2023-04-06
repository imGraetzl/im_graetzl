namespace :scheduled do
  desc 'Set new startDate if in past and additional future Date exists'
  task update_meeting_date: :environment do

    # Create Activity for Meetings which had no Activity on Creating
    Meeting.where("starts_at_date = ?", Date.today + 2.month).find_each do |meeting|
      ActionProcessor.track(meeting, :create) if meeting.refresh_activity
    end

    # Delete all PAST Additonal Dates
    MeetingAdditionalDate.where('starts_at_date < ?', Date.today).each do |model|
      model.destroy
    end

    # Update past meetings to next additional date and may refresh activity
    Meeting.where("starts_at_date = ?", Date.yesterday).find_each do |meeting|
      if meeting.meeting_additional_dates.any?
        meeting.set_next_date!
        ActionProcessor.track(meeting, :create) if meeting.refresh_activity
      end
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

  desc 'Disable Meetings after 1 year'
  task disable_past_meetings: :environment do
    Meeting.active.where("ends_at_date = ?", 12.months.ago).find_each do |meeting|
      meeting.update_attribute(:state, "disabled")
    end
    Meeting.active.where(ends_at_date: nil).where("starts_at_date = ?", 12.months.ago).find_each do |meeting|
      meeting.update_attribute(:state, "disabled")
    end
  end

end
