class MeetingMailerPreview < ActionMailer::Preview

  def message_to_user
    MeetingMailer.message_to_user(Meeting.first, User.first, User.last, "Hello", "Hello world")
  end

  def create_meeting_reminder
    MeetingMailer.create_meeting_reminder(Meeting.last)
  end

end
