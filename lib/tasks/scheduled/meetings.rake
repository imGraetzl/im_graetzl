namespace :scheduled do
  desc 'Set new startDate if in past and additional future Date exists'
  task update_meeting_date: :environment do

    # Create Activity for Meetings which had no Activity on Creating
    Meeting.where("starts_at_date = ?", Date.today + 2.month).find_each do |meeting|

      if !Notification.where(subject: meeting).where('notify_before > ?', Date.today).any?
        ActionProcessor.track(meeting, :create)
      end

    end

    # Delete all PAST Additonal Dates
    MeetingAdditionalDate.where('starts_at_date < ?', Date.today).each do |model|
      model.destroy
    end

    # Update past meetings to next additional date and may refresh activity
    Meeting.where("starts_at_date = ?", Date.yesterday).find_each do |meeting|
      if meeting.meeting_additional_dates.any? 
        meeting.set_next_date!
        ActionProcessor.track(meeting, :create) if (meeting.refresh_activity || meeting.entire_region?)
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

  desc 'Send Good Morning Date Invite'
  task good_morning_date_invite: :environment do
    region = Region.get('wien')
    category = EventCategory.where("title ILIKE :q", q: "%Good Morning%").last
    meetings = Meeting.joins(:event_categories).where(event_categories: {id: category&.id})
    
    meetings.in(region).where(starts_at_date: 15.days.from_now).find_each do |meeting|
      #User.confirmed.in(region).where(newsletter: true).joins(:favorite_graetzls).where(favorite_graetzls: {id: meeting.graetzl.id}).or(User.confirmed.where(newsletter: true).where(graetzl_id: meeting.graetzl.id)).distinct.find_each do |user|
      User.confirmed.in(region).where(newsletter: true).joins(:districts).where(districts: {id: meeting.graetzl.district.id}).find_each do |user|
        next if meeting.users.include?(user)
        MeetingMailer.good_morning_date_invite(user, meeting).deliver_now
      end
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
