module User::SummaryNotifications
  extend ActiveSupport::Concern

  def notifications_of_the_day
    notifications.where(["bitmask & ? > 0", daily_mail_notifications]).
                      where("created_at >= NOW() - interval '5 minutes'").
                      where(sent: false)
  end

  def notifications_of_the_week
    notifications.where(["bitmask & ? > 0", weekly_mail_notifications]).
                      where("created_at >= NOW() - interval '30 minutes'").
                      where(sent: false)
  end
end
