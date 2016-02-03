class SendMailNotificationJob
  include SuckerPunch::Job

  def perform(notification)
    SuckerPunch.logger.info ('Perform SendMailNotificationJob')
    Notifications::ImmediateMail.new(notification).deliver
  end
end
