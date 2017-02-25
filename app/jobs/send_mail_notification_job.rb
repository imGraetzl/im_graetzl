class SendMailNotificationJob < ApplicationJob

  def perform(notification)
    SuckerPunch.logger.info "SendMailNotificationJob start at: #{Time.now}"
    Notification::ImmediateMail.new(notification).deliver
  end
end
