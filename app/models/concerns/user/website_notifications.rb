module User::WebsiteNotifications
  extend ActiveSupport::Concern

  def enabled_website_notification?(type)
    enabled_website_notifications & type::BITMASK > 0
  end

  # TODO only used in specs -> not necessary?
  def enable_website_notification(type)
    new_setting = enabled_website_notifications | type::BITMASK
    update_attribute(:enabled_website_notifications, new_setting)
  end

  def toggle_website_notification(type)
    new_setting = enabled_website_notifications ^ type::BITMASK
    update_attribute(:enabled_website_notifications, new_setting)
  end

  def website_notifications
    notifications.where(["bitmask & ? > 0", enabled_website_notifications]).where(display_on_website: true)
  end

  def new_website_notifications_count
    website_notifications.where(seen: false).count
  end
end
