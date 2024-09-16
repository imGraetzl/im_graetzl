class NotificationMailerPreview < ActionMailer::Preview

  def send_immediate
    notification = Notifications::NewEnergyOffer.last
    NotificationMailer.send_immediate(notification)
  end

  def summary_graetzl
    region = Region.get('wien')
    zuckerls = Zuckerl.in(region).live.include_for_box
    subscriptions = Subscription.in(region).active
    good_morning_dates = Meeting.in(region).good_morning_dates.upcoming
    NotificationMailer.summary_graetzl(prepare_user, prepare_user.region, 'weekly', zuckerls, subscriptions, good_morning_dates)
  end

  def summary_personal
    NotificationMailer.summary_personal(prepare_user, prepare_user.region, 'weekly')
  end

  private

  def prepare_user
    #user = User.where(email: 'michael.walchhuetter@gmail.com').first
    user = User.where(region_id: 'wien').last
    user.notifications.update_all(sent: false)
    user
  end

end
