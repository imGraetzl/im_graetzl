class Notifications::CommentInMeeting < Notification

  TRIGGER_KEY = 'meeting.comment'
  BITMASK = 128

  def self.receivers(activity)
    activity.trackable.users
  end

  def self.description
    "Neuer Kommentar bei einem Treffen an dem ich teilnehme"
  end

  def mail_vars
    {
      meeting_name: activity.trackable.name,
      meeting_url: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS),
      comment_url: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS),
      comment_content: activity.recipient.content.truncate(300, separator: ' '),
      owner_name: activity.owner.username,
      owner_url: user_url(activity.owner, DEFAULT_URL_OPTIONS),
      owner_avatar_url: ApplicationController.helpers.attachment_url(activity.owner, :avatar, :fill, 40, 40, host: "http://#{DEFAULT_URL_OPTIONS[:host]}") || ApplicationController.helpers.image_url('avatar/user/40x40.png', host: "http://#{DEFAULT_URL_OPTIONS[:host]}"),
    }
  end

  def mail_subject
    "Neuer Kommentar bei einem Treffen"
  end
end
