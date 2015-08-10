class CreateWebsiteNotificationsJob < ActiveJob::Base
  queue_as :default

  def perform(activity_id)
    activity = PublicActivity::Activity.find(activity_id)
    Notification.broadcast(activity)
  end
end
