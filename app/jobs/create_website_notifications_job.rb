class CreateWebsiteNotificationsJob < ActiveJob::Base
  queue_as :default

  #def perform(activity_id)
  def perform(activity)
    #ActiveRecord::Base.connection_pool.with_connection do
      #activity = PublicActivity::Activity.find(activity_id)
      Notification.broadcast(activity)
    #end
  end
end
