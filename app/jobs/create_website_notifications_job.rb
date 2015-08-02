class CreateWebsiteNotificationsJob < ActiveJob::Base
  queue_as :default

  def perform(activity_id)
    activity = PublicActivity::Activity.find(activity_id)
    triggered_types = Notification::TYPES.select { |t| t.trigger_key == activity.key }
    already_notified = [ ]
    triggered_types.sort { |a, b| a.bitmask <=> b.bitmask  }.each do |type|
      type.broadcast(activity, already_notified)
    end
  end
end
