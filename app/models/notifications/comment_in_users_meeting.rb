class Notifications::CommentInUsersMeeting < Notification

  TRIGGER_KEY = 'meeting.comment'
  BITMASK = 16

  def self.receivers(activity)
    User.where(id: activity.trackable.initiator.id)
  end

  def self.condition(activity)
    activity.trackable.initiator.present? && activity.trackable.initiator.id != activity.owner_id
  end

  def self.description
    "Mein erstelltes Treffen wurde kommentiert"
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
    "Neuer Kommentar in deinem Treffen"
  end
end
