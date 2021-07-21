class ActivityStream

  def initialize(graetzl, district, current_user)

    district ? @area = district : @area = graetzl
    @user = current_user #Notification Test

  end

  def fetch
    activities = [
      Activity.where(trackable_id: @area.meetings.non_private.pluck(:id), key: ['meeting.comment', 'meeting.create', 'meeting.go_to']),
      Activity.where(trackable_id: @area.location_ids, key: ['location.create']),
      Activity.where(trackable_id: @area.location_post_ids, key: ['location_post.comment', 'location_post.create']),
      Activity.where(trackable_id: @area.room_offer_ids, key: ['room_offer.create', 'room_offer.update', 'room_offer.comment']),
      Activity.where(trackable_id: @area.room_demand_ids, key: ['room_demand.create', 'room_demand.update', 'room_demand.comment']),
      Activity.where(trackable_id: @area.room_call_ids, key: ['room_call.create']),
      Activity.where(trackable_id: @area.tool_offers.pluck(:id), key: ['tool_offer.create', 'tool_offer.comment']),
      Activity.where(trackable_id: @area.groups.pluck(:id), key: ['group.create']),

      # Used for cross_platform Meetings:
      Activity.where(trackable_id: Meeting.non_private.pluck(:id), cross_platform: true, key: ['meeting.comment', 'meeting.create', 'meeting.go_to']),
      #Activity.where(cross_platform: true, key: ['meeting.comment', 'meeting.create', 'meeting.go_to']),

      # Personal Activity Stream build on User Notifications
      Activity.where(id: @user.notifications.where(:type => "Notifications::NewGroupDiscussion").pluck(:activity_id)),

    ].reduce(:or)

    activity_ids = activities.select('DISTINCT ON(trackable_id, trackable_type) id')
    activity_ids = activity_ids.order(:trackable_id, :trackable_type, id: :desc)
    Activity.includes(:owner, :trackable).where(id: activity_ids).order(id: :desc)
  end

  def insert_zuckerls(activity_items)
    zuckerls_sample_size = activity_items.size * 0.2
    zuckerls = Zuckerl.for_area(@area).limit(zuckerls_sample_size).order(Arel.sql("RANDOM()")).to_a
    zuckerl_items = Array.new(activity_items.size){|i| zuckerls[i] || nil}.shuffle
    activity_items.zip(zuckerl_items).flatten.compact
  end

end
