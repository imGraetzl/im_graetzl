class Notifications::CommentOnDiscussionPost < Notification
  TRIGGER_KEY = 'discussion_post.comment'
  DEFAULT_INTERVAL = :daily
  BITMASK = 2**4

  def self.receivers(activity)
    User.where(id: activity.trackable.user_id)
  end

  def self.description
    "Meine erstellten Inhalte wurden kommentiert"
  end

  def custom_mail_vars
    {
      type: 'commented_discussion_post',
      headline: group.title,
      title: activity.trackable.discussion.title,
      url: group_discussion_url(group, activity.trackable.discussion),
      comment_content: activity.trackable.comments.find_by_id(activity.recipient_id).content.truncate(300, separator: ' '),
      comment_url: group_discussion_url(group, activity.trackable.discussion, :target => "comment_#{activity.recipient_id}"),
      post_url: group_discussion_url(group, activity.trackable.discussion, :target => "discussion-post-#{activity.trackable.id}"),
      owner_name: activity.owner.first_name,
      owner_url: user_url(activity.owner, DEFAULT_URL_OPTIONS),
      owner_avatar_url: Notifications::ImageService.new.avatar_url(activity.owner),
    }
  end

  def mail_subject
    "#{activity.owner.username} hat deinen Beitrag kommentiert."
  end

  def group
    activity.trackable.group
  end

  def group_discussion_post_id
    activity.trackable.id
  end

end
