namespace :db do

  desc 'Migrate Notifications'
  task migrate_notifications: :environment do
    Activity.all.find_each(order: :desc) do |activity|
      Activity.where(subject: activity.subject).where("id < ?", activity.id).delete_all
    end

    Activity.where(subject_type: "LocationPost").find_each do |activity|
      activity.update_columns(
        subject_type: 'Location',
        subject_id: activity.subject.location_id,
        child_type: 'LocationPost',
        child_id: activity.subject_id,
      )
    end

    Activity.where(subject_type: ["Comment", "GroupUser", "RoomRental", "ToolRental", "DiscussionPost"]).delete_all

    print "Updating Activity table...\n"
    Activity.includes(:subject).find_each do |activity|
      print "#{activity.id} #{activity.subject_type} #{activity.subject_id}\n"

      subject = activity.subject
      if subject.is_a?(Meeting) && subject.private?
        activity.destroy
        next
      end

      activity.update(region_id: subject.region_id)

      if subject.is_a?(Meeting) && subject.online_meeting?
        activity.update(entire_region: true, graetzls: subject.region.graetzls)
      elsif subject.is_a?(Discussion)
        activity.update(group_id: subject.group_id, graetzls: subject.group.graetzls)
      elsif subject.respond_to?(:graetzls)
        activity.update(graetzls: subject.graetzls)
      elsif subject.respond_to?(:graetzl)
        activity.update(graetzls: [subject.graetzl])
      end
    end

    Notification.includes(:subject).find_each do |notification|
      activity.update(region_id: activity.subject.region_id)
    end

    Notification.where(bitmask: 2**4).update_all(type: 'Notifications::CommentOnOwnedContent')
    Notification.where(bitmask: 2**6).update_all(type: 'Notifications::CommentOnFollowedContent')
    Notification.where(bitmask: 2**9).update_all(type: 'Notifications::MeetingAttended')
    Notification.where(bitmask: 2**21).update_all(type: 'Notifications::ReplyOnComment')

    Notification.where(type: 'Notifications::NewRoomRental').update_all(type: 'Notifications::RoomRentalCreated')
    Notification.where(type: 'Notifications::ApproveRoomRental').update_all(type: 'Notifications::RoomRentalApproved')
    Notification.where(type: 'Notifications::CancelRoomRental').update_all(type: 'Notifications::RoomRentalCanceled')
    Notification.where(type: 'Notifications::RejectRoomRental').update_all(type: 'Notifications::RoomRentalRejected')
    Notification.where(type: 'Notifications::NewToolRental').update_all(type: 'Notifications::ToolRentalCreated')
    Notification.where(type: 'Notifications::ApproveToolRental').update_all(type: 'Notifications::ToolRentalApproved')
    Notification.where(type: 'Notifications::CancelToolRental').update_all(type: 'Notifications::ToolRentalCanceled')
    Notification.where(type: 'Notifications::RejectToolRental').update_all(type: 'Notifications::ToolRentalRejected')
    Notification.where(type: 'Notifications::ReturnPendingToolRental').update_all(type: 'Notifications::ToolRentalReturnPending')
    Notification.where(type: 'Notifications::ReturnConfirmedToolRental').update_all(type: 'Notifications::ToolRentalReturnConfirmed')
    Notification.where(type: 'Notifications::AlsoCommentedDiscussionPost').update_all(type: 'Notifications::ReplyOnFollowedDiscussionPost')
    Notification.where(type: 'Notifications::AlsoCommentedComment').update_all(type: 'Notifications::ReplyOnFollowedComment')
    Notification.where(type: ['Notifications::NewGroup', 'Notifications::NewGroupUser']).delete_all

    Notification.includes(activity: [:subject, :child]).find_each do |notification|
      print "Notification #{notification.id}\n"
      notification.update_columns(
        subject_type: notification.activity.subject_type,
        subject_id: notification.activity.subject_id,
        child_type: notification.activity.child_type,
        child_id: notification.activity.child_id,
        region_id: notification.activity.subject.region_id,
      )
    end
  end

end
