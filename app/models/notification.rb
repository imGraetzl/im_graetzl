class Notification < ActiveRecord::Base
  class Type
    attr_reader :trigger_key, :bitmask

    def initialize(trigger_key, bitmask, &broadcast)
      @trigger_key = trigger_key
      @broadcast = broadcast
      @bitmask = bitmask
    end

    def broadcast(activity, already_notified)
      @broadcast.call(activity, already_notified)
    end
  end

  TYPE_BITMASKS = {
    new_meeting_in_graetzl: 1,
    new_post_in_graetzl: 2,
    update_of_meeting: 4,
    initiator_comments: 8,
    user_comments_users_meeting: 16,
    another_user_comments: 32,
    another_attendee: 64,
    attendee_left: 128
  }
  
  TYPES = [
    # New meeting in user's graetzl
    Type.new('meeting.create', TYPE_BITMASKS[:new_meeting_in_graetzl]) do |activity, already_notified|
      meeting = activity.trackable
      users = User.where(graetzl_id: meeting.graetzl_id)
      users = users.reject { |u| already_notified.include?(u.id) }
      users.reject { |u| u.id == activity.owner_id }.each do |u|
        already_notified << u.id
        u.notifications.create(activity: activity,
                               bitmask: TYPE_BITMASKS[:new_meeting_in_graetzl])
      end
    end,

    # New post in user's graetzl
    Type.new('post.create', TYPE_BITMASKS[:new_post_in_graetzl]) do |activity, already_notified|
      post = activity.trackable
      users = User.where(graetzl_id: post.graetzl_id)
      users = users.reject { |u| already_notified.include?(u.id) }
      users.reject { |u| u.id == activity.owner_id }.each do |u|
        already_notified << u.id
        u.notifications.create(activity: activity,
                               bitmask: TYPE_BITMASKS[:new_post_in_graetzl])
      end
    end,

    # Update of meeting that the user attends
    Type.new('meeting.update', TYPE_BITMASKS[:update_of_meeting]) do |activity, already_notified|
      meeting = activity.trackable
      users = meeting.users
      users = users.reject { |u| already_notified.include?(u.id) }
      users.reject { |u| u.id == activity.owner_id }.each do |u|
        already_notified << u.id
        u.notifications.create(activity: activity,
                               bitmask: TYPE_BITMASKS[:update_of_meeting])
      end
    end,

    # New comment on meeting that the user attends by the initiator
    Type.new('meeting.comment', TYPE_BITMASKS[:initiator_comments]) do |activity, already_notified|
      meeting = activity.trackable
      if (meeting.initiator.present? &&
          meeting.initiator.id == activity.owner_id)
        users = meeting.users
        users = users.reject { |u| u.id == activity.owner_id }
        users = users.reject { |u| already_notified.include?(u.id) }
        users.each do |u|
          already_notified << u.id
          u.notifications.create(activity: activity,
                                 bitmask: TYPE_BITMASKS[:initiator_comments])
        end
      end
    end,

    # New comment on meeting that the user initiated
    Type.new('meeting.comment', TYPE_BITMASKS[:user_comments_users_meeting]) do |activity, already_notified|
      meeting = activity.trackable
      if (meeting.initiator.present? &&
        meeting.initiator.id != activity.owner_id &&
        !already_notified.include?(meeting.initiator.id))
        already_notified << meeting.initiator.id
        meeting.initiator.notifications.create(activity: activity,
                                               bitmask: TYPE_BITMASKS[:user_comments_users_meeting])
      end
    end,

    # New comment on meeting that the user attends by another attendee
    Type.new('meeting.comment', TYPE_BITMASKS[:another_user_comments]) do |activity, already_notified|
      meeting = activity.trackable
      users = meeting.users
      users = users.reject { |u| already_notified.include?(u.id) }
      users.reject { |u| u.id == activity.owner_id }.each do |u|
        already_notified << u.id
        u.notifications.create(activity: activity,
                               bitmask: TYPE_BITMASKS[:another_user_comments])
      end
    end,

    # New attendee on meeting that the user initiated
    Type.new('meeting.go_to', TYPE_BITMASKS[:another_attendee]) do |activity, already_notified|
      meeting = activity.trackable
      if (meeting.initiator.present? &&
          meeting.initiator.try(:id) != activity.owner_id &&
          !already_notified.include?(meeting.initiator.id))
        already_notified << meeting.initiator.id
        meeting.initiator.notifications.create(activity: activity,
                                                        bitmask: TYPE_BITMASKS[:another_attendee])
      end
    end,

    # New attendee on meeting that the user initiated
    Type.new('meeting.left', TYPE_BITMASKS[:attendee_left]) do |activity, already_notified|
      meeting = activity.trackable
      if (meeting.initiator.present? &&
          meeting.initiator.try(:id) != activity.owner_id &&
          !already_notified.include?(meeting.initiator.id))
        already_notified << meeting.initiator.id
        meeting.initiator.notifications.create(activity: activity,
                                                        bitmask: TYPE_BITMASKS[:attendee_left])
      end
    end
  ]

  belongs_to :user
  belongs_to :activity, :class => PublicActivity::Activity

  def self.receive_new_activity(activity)
    triggered_types = TYPES.select { |t| t.trigger_key == activity.key }
    already_notified = [ ]
    triggered_types.sort { |a, b| a.bitmask <=> b.bitmask  }.each do |type|
      type.broadcast(activity, already_notified)
    end
  end

  PublicActivity::Activity.after_create do |activity|
    Notification.receive_new_activity(activity)
  end
end
