class SendMailNotificationJob
  include SuckerPunch::Job

  def perform(notification_id)
    SuckerPunch.logger.info "SendMailNotificationJob start at: #{Time.now}"
    notification = Notification.find notification_id
    Notifications::ImmediateMail.new(notification).deliver
  end
end
