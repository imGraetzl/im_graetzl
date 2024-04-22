class NotificationMailerPreview < ActionMailer::Preview

  def send_immediate
    notification = Notifications::NewEnergyOffer.last
    NotificationMailer.send_immediate(notification)
  end

  def summary_graetzl
    NotificationMailer.summary_graetzl(prepare_user, prepare_user.region, 'weekly')
  end

  def summary_personal
    NotificationMailer.summary_personal(prepare_user, prepare_user.region, 'weekly')
  end

  private

  def prepare_user
    #user = User.where(email: 'michael.walchhuetter@gmail.com').first
    user = User.where(region_id: 'graz').last
    user.notifications.update_all(sent: false)
    user
  end

end
