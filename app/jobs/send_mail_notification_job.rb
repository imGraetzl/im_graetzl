class SendMailNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(user_id, activity_id, type)
  end
end
