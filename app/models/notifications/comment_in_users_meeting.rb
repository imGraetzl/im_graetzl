class Notifications::CommentInUsersMeeting < Notification
  TRIGGER_KEY = 'meeting.comment'
  DEFAULT_INTERVAL = :daily
  BITMASK = 2**4

  def self.receivers(activity)
    User.where(id: activity.trackable.user_id)
  end

  def self.condition(activity)
    activity.trackable.user.present? && activity.trackable.user_id != activity.owner_id
  end

  def self.description
    'Meine erstellten Inhalte wurden kommentiert'
  end

  def custom_mail_vars
    {
      #meeting_name: activity.trackable.name,
      #meeting_url: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS),
      type: 'commented',
      headline: 'Neuer Kommentar bei deinem Treffen:',
      title: activity.trackable.name,
      url: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS),
      comment_url: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, DEFAULT_URL_OPTIONS),
      comment_content: activity.recipient.content.truncate(300, separator: ' '),
      owner_name: activity.owner.username,
      owner_url: user_url(activity.owner, DEFAULT_URL_OPTIONS),
      owner_avatar_url: Notifications::ImageService.new.avatar_url(activity.owner)
    }
  end

  def mail_subject
    "#{activity.owner.username} hat dein Treffen kommentiert."
  end
end
