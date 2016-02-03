module User::MailNotifications
  extend ActiveSupport::Concern

  def mail_notifications(interval)
    notifications.where(["bitmask & ? > 0", send("#{interval}_mail_notifications".to_sym)])
  end

  def enabled_mail_notification?(type, interval)
    send("#{interval}_mail_notifications".to_sym) & type::BITMASK > 0
  end

  def enable_mail_notification(type, interval)
    [ :immediate, :daily, :weekly ].each do |i|
      disable_mail_notification(type, i)
    end

    new_setting = send("#{interval}_mail_notifications".to_sym) | type::BITMASK
    update_attribute("#{interval}_mail_notifications".to_sym, new_setting)
  end

  def disable_mail_notification(type, interval)
    mask = "11111111111111".to_i(2) ^ type::BITMASK
    new_setting = send("#{interval}_mail_notifications".to_sym) & mask
    update_attribute("#{interval}_mail_notifications".to_sym, new_setting)
  end
end
