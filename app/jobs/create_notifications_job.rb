class CreateNotificationsJob
  include SuckerPunch::Job

  def perform(activity)
    SuckerPunch.logger.info ('Perform CreateWebsiteNotificationsJob')
    ActiveRecord::Base.connection_pool.with_connection do
      Notification.broadcast(activity)
    end
  end
end
