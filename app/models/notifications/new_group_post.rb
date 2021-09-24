class Notifications::NewGroupPost < Notification
  DEFAULT_INTERVAL = :daily
  self.class_bitmask = 2**18

  def self.description
    'Es gibt neue Beiträge in Themen denen ich folge'
  end

  def mail_subject
    "Neuer Beitrag von #{subject.user.first_name} im Thema #{subject.discussion.title}."
  end

  def group
    discussion_post.group
  end

  def discussion
    discussion_post.discussion
  end

  def discussion_post
    subject
  end

end
