class CreateNotificationsJob
  include SuckerPunch::Job

  def perform(activity_id)
    SuckerPunch.logger.info ("CreateWebsiteNotificationsJob start at: #{Time.now}")
    ActiveRecord::Base.connection_pool.with_connection do
      activity = PublicActivity::Activity.find activity_id
      Notification.broadcast(activity)
    end
  end
end
