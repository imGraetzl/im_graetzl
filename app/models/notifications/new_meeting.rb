class Notifications::NewMeeting < Notification

  TRIGGER_KEY = 'meeting.create'
  BITMASK = 1 #TODO autosave right bitmask attribute for new records...

    # new_meeting_in_graetzl: {
    #   bitmask: 1,
    #   triggered_by_activity_with_key: 'meeting.create',
    #   receivers: ->(activity) { User.where(graetzl_id: activity.trackable.graetzl_id) }
    # },


  def self.receivers(activity)
    User.where(graetzl_id: activity.trackable.graetzl_id)
  end

  # def self.triggered_by?(activity)
  #   activity.key == self.class::TRIGGER_KEY
  # end
end
