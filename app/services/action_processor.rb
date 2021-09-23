class ActionProcessor

  def self.track(object, action, child = nil)
    case [object.class, action]

    when [Location, :create]
      Activity.add_public(object, to: object.graetzl)
      Notifications::NewLocation.generate(object, to: object.graetzl.user_ids - [object.user_id])

    when [Location, :post]
      Activity.add_public(object, child, to: object.graetzl)
      Notifications::NewLocationPost.generate(object, to: object.graetzl.user_ids - [child.user_id])

    when [Location, :comment]
      Activity.add_public(object, child, to: object.graetzl)
      notify_comment(object, child)

    when [Meeting, :create]
      if object.public?
        Activity.add_public(object, to: object.online_meeting? ? :entire_region : object.graetzl)
      end

      if object.group_id
        Notifications::NewGroupMeeting.generate(object, to: object.group.users - [object.user_id],
          time_range: object.notification_time_range)
      elsif object.public?
        Notifications::NewMeeting.generate(object, to: object.graetzl.user_ids - [object.user_id],
          time_range: object.notification_time_range)
      end

    when [Meeting, :attended]
      if object.public?
        Activity.add_public(object, child, to: object.online_meeting? ? :entire_region : object.graetzl)
      end
      Notifications::MeetingAttended.generate(object, child, to: object.user_id) if object.user_id != child.user_id

    when [Meeting, :comment]
      if object.public?
        Activity.add_public(object, child, to: object.online_meeting? ? :entire_region : object.graetzl)
      end
      notify_comment(object, child)

    when [Discussion, :create]
      Activity.add_personal(object, group: object.group)
      Notifications::NewGroupDiscussion.generate(object, to: object.group.user_ids)

    when [Discussion, :create_without_notify]
      Activity.add_personal(object, group: object.group)

    when [DiscussionPost, :create]
      Notifications::NewGroupPost.generate(object, to: object.discussion.following_user_ids)

    when [DiscussionPost, :comment]
      if object.user_id != child.user_id
        Notifications::CommentOnDiscussionPost.generate(object, child, to: object.user_id)
      end
      comment_followers = object.comments.pluck(:user_id) - [object.user_id, child.user_id]
      Notifications::ReplyOnFollowedDiscussionPost.generate(object, child, to: comment_followers)

    when [RoomCall, :create]
      Activity.add_public(object, to: object.graetzl)

    when [RoomOffer, :create]
      Activity.add_public(object, to: object.graetzl)
      Notifications::NewRoomOffer.generate(object, to: object.graetzl.user_ids - [object.user_id])

    when [RoomOffer, :update]
      Activity.add_public(object, to: object.graetzl)

    when [RoomOffer, :comment]
      Activity.add_public(object, child, to: object.graetzl)
      notify_comment(object, child)

    when [RoomDemand, :create]
      Activity.add_public(object, to: object.graetzls)
      Notifications::NewRoomDemand.generate(object, to: object.graetzl.user_ids - [object.user_id])

    when [RoomDemand, :update]
      Activity.add_public(object, to: object.graetzls)

    when [RoomDemand, :comment]
      Activity.add_public(object, child, to: object.graetzls)
      notify_comment(object, child)

    when [ToolOffer, :create]
      Activity.add_public(object, to: object.graetzl)
      Notifications::NewToolOffer.generate(object, to: object.graetzl.user_ids - [object.user_id])

    when [ToolOffer, :comment]
      Activity.add_public(object, to: object.graetzl)
      notify_comment(object, child)

    when [CoopDemand, :create]
      Activity.add_public(object, to: object.graetzls)

    when [CoopDemand, :update]
      Activity.add_public(object, to: object.graetzls)

    when [User, :comment]
      Notifications::NewWallComment.generate(object, child, to: object.id)

    when [Comment, :comment]
      if object.user_id != child.user_id
        Notifications::ReplyOnComment.generate(object.commentable, child, to: object.user_id)
      end
      comment_followers = object.comments.pluck(:user_id) - [object.user_id, child.user_id]
      Notifications::ReplyOnFollowedComment.generate(object.commentable, child, to: comment_followers)

    else
      raise "Action not defined for #{object.class} #{action}"
    end
  end

  def self.notify_comment(object, comment)
    if comment.user_id != object.user_id
      Notifications::CommentOnOwnedContent.generate(object, comment, to: object.user_id)
    end
    comment_followers = object.comments.pluck(:user_id) - [object.user_id, comment.user_id]
    Notifications::CommentOnFollowedContent.generate(object, comment, to: comment_followers)
  end

end