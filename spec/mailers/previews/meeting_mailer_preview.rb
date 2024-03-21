class MeetingMailerPreview < ActionMailer::Preview

  def message_to_user
    MeetingMailer.message_to_user(Meeting.first, User.first, User.last, "Hello", "Hello world")
  end

  def create_meeting_reminder
    MeetingMailer.create_meeting_reminder(Meeting.last)
  end

  def good_morning_date_invite
    region = Region.get('wien')
    MeetingMailer.good_morning_date_invite(User.in(region).last, Meeting.in(region).last)
  end

end
