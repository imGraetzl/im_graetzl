# class CreateWebsiteNotificationsJob < ActiveJob::Base
  # queue_as :default
class CreateWebsiteNotificationsJob
  include SuckerPunch::Job

  #def perform(activity_id)
  def perform(activity)
    SuckerPunch.logger.info ('Perform CreateWebsiteNotificationsJob')
    ActiveRecord::Base.connection_pool.with_connection do
      #activity = PublicActivity::Activity.find(activity_id)
      Notification.broadcast(activity)
    end
  end
end
