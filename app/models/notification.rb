class Notification < ActiveRecord::Base

  TYPES = {
    new_meeting_in_graetzl: {
      bitmask: 1,
      triggered_by_activity_with_key: 'meeting.create',
      receivers: ->(activity) { User.where(graetzl_id: activity.trackable.graetzl_id) }
    },
    new_post_in_graetzl: {
      bitmask: 2,
      triggered_by_activity_with_key: 'post.create',
      receivers: ->(activity) { User.where(graetzl_id: activity.trackable.graetzl_id) }
    },
    update_of_meeting: {
      triggered_by_activity_with_key: 'meeting.update',
      bitmask: 4,
      receivers: ->(activity) { activity.trackable.users }
    },
    initiator_comments: {
      bitmask: 8,
      triggered_by_activity_with_key: 'meeting.comment',
      receivers: ->(activity) { activity.trackable.users },
      condition: ->(activity) { activity.trackable.initiator.present? && activity.trackable.initiator.id == activity.owner_id }
    },
    user_comments_users_meeting: {
      triggered_by_activity_with_key: 'meeting.comment',
      bitmask: 16,
      receivers: ->(activity) { User.where(["id = ?", activity.trackable.initiator.id]) },
      condition: ->(activity) { activity.trackable.initiator.present? && activity.trackable.initiator.id != activity.owner_id }
    },
    another_user_comments: {
      triggered_by_activity_with_key: 'meeting.comment',
      bitmask: 32,
      receivers: ->(activity) { activity.trackable.users }
    },
    another_attendee: {
      triggered_by_activity_with_key: 'meeting.go_to',
      bitmask: 64,
      receivers: ->(activity) { User.where(["id = ?", activity.trackable.initiator.id]) },
      condition: ->(activity) { activity.trackable.initiator.present? && activity.trackable.initiator.id != activity.owner_id }
    },
    attendee_left: {
      triggered_by_activity_with_key: 'meeting.left',
      bitmask: 128,
      receivers: ->(activity) { User.where(["id = ?", activity.trackable.initiator.id]) },
      condition: ->(activity) { activity.trackable.initiator.present? && activity.trackable.initiator.id != activity.owner_id }
    },
    new_wall_comment: {
      triggered_by_activity_with_key: 'user.comment',
      bitmask: 256,
      receivers: ->(activity) { User.where(["id = ?", activity.trackable.id]) },
      condition: ->(activity) { activity.owner.present? && activity.recipient.present? }
    },
    cancel_of_meeting: {
      triggered_by_activity_with_key: 'meeting.cancel',
      bitmask: 512,
      receivers: ->(activity) { activity.trackable.users }
    },
    approve_of_location: {
      triggered_by_activity_with_key: 'location.approve',
      bitmask: 1024,
      receivers: ->(activity) { activity.trackable.users }
    }
  }

  belongs_to :user
  belongs_to :activity, :class => PublicActivity::Activity

  def self.receive_new_activity(activity)
    #CreateWebsiteNotificationsJob.perform_later(activity.id)
    CreateWebsiteNotificationsJob.later(30, activity.id)
  end

  def self.broadcast(activity)
    triggered_types = TYPES.select { |k, v| v[:triggered_by_activity_with_key] == activity.key }
    ids_notified_users =  []
    #sort by bitmask, so that lower order bitmask types are sent first, because
    #higher order bitmask types might not needed to be sent at all, when a user
    #has been already notified via a lower order type.
    triggered_types.keys.sort { |a,b| triggered_types[a][:bitmask] <=> triggered_types[b][:bitmask] }.each do |k|
      v = triggered_types[k]
      if v[:condition].nil? || v[:condition].call(activity)
        users = v[:receivers].call(activity)
        #users = users.merge(User.where(["enabled_website_notifications & ? > 0", v[:bitmask]]))
        users.each do |u|
          unless ids_notified_users.include?(u.id) || (u.id == activity.owner.id if activity.owner)
            display_on_website = u.enabled_website_notifications & v[:bitmask] > 0
            n = u.notifications.create(activity: activity, bitmask: v[:bitmask], display_on_website: display_on_website)
            ids_notified_users << u.id if display_on_website
            if !Rails.env.development? && (u.immediate_mail_notifications & v[:bitmask] > 0)
              SendMailNotificationJob.perform_later(u.id, "immediate", n.id)
              ids_notified_users << u.id
            end
          end
        end
      end
    end
  end

  PublicActivity::Activity.after_create do |activity|
    Notification.receive_new_activity(activity)
  end
end
