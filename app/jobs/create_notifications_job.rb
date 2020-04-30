class CreateNotificationsJob < ApplicationJob

  def perform(activity)
    ActiveRecord::Base.connection_pool.with_connection do
      Notification.broadcast(activity)
    end
  end
end
