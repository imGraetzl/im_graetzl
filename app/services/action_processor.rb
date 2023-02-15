class ActionProcessor

  def self.track(subject, action, child = nil)
    new.delay.track(subject, action, child)
  end

  def track(subject, action, child = nil)
    case [subject.class, action]

    when [Location, :create]
      Activity.add_public(subject, to: subject.graetzl)
      Notifications::NewLocation.generate(subject, to: user_ids(subject.graetzl))

    when [Location, :post]

      # Delete existing Notifications for LocationPosts (for only having the newest in Mails)
      Notification.where(subject: subject).where(child_type: 'LocationPost').delete_all
      Activity.add_public(subject, child, to: subject.graetzl)
      Notifications::NewLocationPost.generate(subject, child, to: user_ids(subject.graetzl))

    when [Location, :menu]
      Activity.add_public(subject, child, to: subject.graetzl)
      Notifications::NewLocationMenu.generate(subject, child, to: user_ids(subject.graetzl),
        time_range: child.notification_time_range)

    when [Location, :comment]
      Activity.add_public(subject, child, to: subject.graetzl)
      notify_comment(subject, child)

    when [LocationPost, :comment]
      if subject.user_id != child.user_id
        Activity.add_public(subject.location, child, to: subject.location.graetzl)
      end
      notify_comment(subject, child)

    when [LocationMenu, :comment]
      if subject.user_id != child.user_id
        Activity.add_public(subject.location, child, to: subject.location.graetzl)
      end
      notify_comment(subject, child)

    when [Meeting, :create]
      if subject.public?
        #Activity.add_public(subject, to: subject.online_meeting? ? :entire_region : subject.graetzl)
        Activity.add_public(subject, to: subject.graetzl)
        Notifications::NewMeeting.generate(subject, to: user_ids(subject.graetzl),
          time_range: subject.notification_time_range, sort_date: subject.notification_sort_date)
      elsif subject.group_id
        Activity.add_personal(subject, group: subject.group)
        Notifications::NewGroupMeeting.generate(subject, to: subject.group.user_ids,
          time_range: subject.notification_time_range, sort_date: subject.notification_sort_date)
      end

    when [Meeting, :update]
      if subject.public?

        # Update existing Notifications to new Dates
        if Notification.where(subject: subject).where(type: 'Notifications::NewMeeting').any?
          Notification.where(subject: subject).where(type: 'Notifications::NewMeeting').update_all(
            notify_at: subject.notification_time_range.first || Time.current,
            notify_before: subject.notification_time_range.last,
            sort_date: subject.notification_sort_date,
          )
        end

      elsif subject.group_id

        # Update existing Notifications to new Dates
        if Notification.where(subject: subject).where(type: 'Notifications::NewGroupMeeting').any?
          Notification.where(subject: subject).where(type: 'Notifications::NewGroupMeeting').update_all(
            notify_at: subject.notification_time_range.first || Time.current,
            notify_before: subject.notification_time_range.last,
            sort_date: subject.notification_sort_date,
          )
        end
        
      end

    when [Meeting, :attended]
      if subject.public?
        Activity.add_public(subject, child, to: subject.graetzl)
      end
      Notifications::MeetingAttended.generate(subject, child, to: subject.user_id) if subject.user_id != child.user_id

    when [Meeting, :comment]
      if subject.public?
        Activity.add_public(subject, child, to: subject.graetzl)
      end
      notify_comment(subject, child)

    when [Discussion, :create]
      Activity.add_personal(subject, group: subject.group)
      Notifications::NewGroupDiscussion.generate(subject, to: subject.group.user_ids)

    when [Discussion, :create_without_notify]
      Activity.add_personal(subject, group: subject.group)

    when [Discussion, :post]
      Activity.add_personal(subject, group: subject.group)

    when [DiscussionPost, :create]
      Notifications::NewGroupPost.generate(subject, to: subject.discussion.following_user_ids)

    when [DiscussionPost, :comment]
      if subject.user_id != child.user_id
        Notifications::CommentOnDiscussionPost.generate(subject, child, to: subject.user_id)
      end
      comment_followers = subject.comments.pluck(:user_id) - [subject.user_id, child.user_id]
      Notifications::ReplyOnFollowedDiscussionPost.generate(subject, child, to: comment_followers)

    when [RoomOffer, :create]
      Activity.add_public(subject, to: subject.graetzl)
      Notifications::NewRoomOffer.generate(subject, to: user_ids(subject.graetzl))

    when [RoomOffer, :update]
      Activity.add_public(subject, to: subject.graetzl)
      Notifications::NewRoomOffer.generate(subject, to: user_ids(subject.graetzl))

    when [RoomOffer, :boost_create]
      Activity.add_public(subject, to: :entire_region)
      # Delete all pending Notifications for same subject and type
      Notification.where(subject: subject).where(type: 'Notifications::NewRoomOffer').delete_all
      # Notify all Users
      Notifications::NewRoomOffer.generate(subject, child, to: User.in(subject.region).all.pluck(:id), time_range: child.notification_time_range, sort_date: child.notification_sort_date)

    when [RoomOffer, :boost_pushup]
      Activity.add_public(subject, to: :entire_region)

    when [RoomOffer, :boost_refund]
      Activity.where(subject: subject).update(graetzl_ids: subject.graetzl.id)
      Notification.where(child: child).delete_all
      Notifications::NewRoomOffer.generate(subject, child, to: user_ids(subject.graetzl), time_range: child.notification_time_range)

    when [RoomOffer, :comment]
      if subject.boosted?
        Activity.add_public(subject, child, to: :entire_region)
      elsif subject.enabled?
        Activity.add_public(subject, child, to: subject.graetzl)
      end
      notify_comment(subject, child)

    when [RoomDemand, :create]
      Activity.add_public(subject, to: subject.graetzls)
      Notifications::NewRoomDemand.generate(subject, to: user_ids(subject.graetzls))

    when [RoomDemand, :update]
      Activity.add_public(subject, to: subject.graetzls)

    when [RoomDemand, :comment]
      if subject.enabled?
        Activity.add_public(subject, child, to: subject.graetzls)
      end
      notify_comment(subject, child)

    when [ToolOffer, :create]
      Activity.add_public(subject, to: subject.graetzl)
      Notifications::NewToolOffer.generate(subject, to: user_ids(subject.graetzl))

    when [ToolOffer, :comment]
      if subject.enabled?
        Activity.add_public(subject, child, to: subject.graetzl)
      end
      notify_comment(subject, child)

    when [ToolDemand, :create]
      Activity.add_public(subject, to: subject.graetzls)
      Notifications::NewToolDemand.generate(subject, to: user_ids(subject.graetzls))

    when [ToolDemand, :update]
      Activity.add_public(subject, to: subject.graetzls)

    when [ToolDemand, :comment]
      if subject.enabled?
        Activity.add_public(subject, child, to: subject.graetzls)
      end
      notify_comment(subject, child)

    when [CoopDemand, :create]
      Activity.add_public(subject, to: subject.graetzls)
      Notifications::NewCoopDemand.generate(subject, to: user_ids(subject.graetzls))

    when [CoopDemand, :update]
      Activity.add_public(subject, to: subject.graetzls)

    when [CoopDemand, :comment]
      if subject.enabled?
        Activity.add_public(subject, child, to: subject.graetzls)
      end
      notify_comment(subject, child)

    when [CrowdCampaign, :create]
      if subject.scope_public?
        Activity.add_public(subject, to: :entire_region)
        Notifications::NewCrowdCampaign.generate(subject, to: User.in(subject.region).all.pluck(:id), time_range: subject.notification_time_range) # Notify all in Region
      end
    when [CrowdPledge, :create]
      if subject.crowd_campaign.scope_public?
        Activity.add_public(subject.crowd_campaign, subject, to: :entire_region)
      end
    when [CrowdDonationPledge, :create]
      if subject.crowd_campaign.scope_public?
        Activity.add_public(subject.crowd_campaign, subject, to: :entire_region)
      end
    when [CrowdCampaign, :comment]
      Activity.add_public(subject, child, to: :entire_region) if subject.scope_public?
      notify_comment(subject, child)

    when [CrowdCampaign, :post]
      if subject.scope_public?
        Activity.add_public(subject, child, to: :entire_region)
        # Delete existing Notifications for CrowdCampaignPosts (for only having the newest in Mails)
        Notification.where(subject: subject).where(child_type: 'CrowdCampaignPost').delete_all
        Notifications::NewCrowdCampaignPost.generate(subject, child, to: User.in(subject.region).all.pluck(:id)) # Notify all in Region
      end
    when [CrowdCampaignPost, :comment]
      notify_comment(subject, child)

    when [User, :comment]
      Notifications::NewWallComment.generate(subject, child, to: subject.id)

    when [Comment, :comment]
      if subject.user_id != child.user_id
        Notifications::ReplyOnComment.generate(subject.commentable, child, to: subject.user_id)
      end
      comment_followers = subject.comments.pluck(:user_id) - [subject.user_id, child.user_id]
      Notifications::ReplyOnFollowedComment.generate(subject.commentable, child, to: comment_followers)

    when [Subscription, :create]
      Activity.add_public(subject, to: :entire_region)

    else
      raise "Action not defined for #{subject.class} #{action}"
    end
  end

  private

  def notify_comment(subject, comment)
    if comment.user_id != subject.user_id
      Notifications::CommentOnOwnedContent.generate(subject, comment, to: subject.user_id)
    end
    comment_followers = subject.comments.pluck(:user_id) - [subject.user_id, comment.user_id]
    Notifications::CommentOnFollowedContent.generate(subject, comment, to: comment_followers)
  end

  def user_ids(graetzls)
    User.where(graetzl_id: Array(graetzls)).pluck(:id) +
    UserGraetzl.where(graetzl_id: Array(graetzls)).pluck(:user_id)
  end

end
