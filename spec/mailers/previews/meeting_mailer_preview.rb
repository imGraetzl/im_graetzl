class MeetingMailerPreview < ActionMailer::Preview

  def message_to_user
    MeetingMailer.message_to_user(Meeting.first, User.first, User.last, "Hello", "Hello world")
  end

  def create_meeting_reminder
    MeetingMailer.create_meeting_reminder(Meeting.last)
  end

  def missing_meeting_category
    MeetingMailer.missing_meeting_category(Meeting.upcoming.last)
  end

end
