class Notifications::AttendeeInUsersMeeting < Notification

  TRIGGER_KEY = 'meeting.go_to'
  BITMASK = 256

  def self.receivers(activity)
    User.where(id: activity.trackable.initiator.id)
  end

  def self.condition(activity)
    activity.trackable.initiator.present? && activity.trackable.initiator.id != activity.owner_id
  end

  def mail_vars
    {
      meeting_name: activity.trackable.name,
      meeting_url: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS),
      owner_name: activity.owner.username,
      owner_url: user_url(activity.owner, DEFAULT_URL_OPTIONS),
      owner_avatar_url: ApplicationController.helpers.attachment_url(activity.owner, :avatar, :fill, 40, 40, fallback: "avatar/user/40x40.png", host: "http://#{DEFAULT_URL_OPTIONS[:host]}"),
    }
  end

  def mail_subject
    "Neuer Teilnehmer an deinem Treffen"
  end
end
