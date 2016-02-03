# class SendMailNotificationJob < ActiveJob::Base
#   queue_as :default
class SendMailNotificationJob
  include SuckerPunch::Job

  def perform(notification)
    SuckerPunch.logger.info ('Perform SendMailNotificationJob')
    mandrill_message = ::Notifications::ImmediateMail.new(notification)
    mandrill_message.send
  end
end
