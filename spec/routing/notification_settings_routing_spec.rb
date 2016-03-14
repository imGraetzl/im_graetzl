require "rails_helper"

RSpec.describe NotificationSettingsController, type: :routing do
  describe 'routes' do
    it 'routes to users/notification_settings/toggle_website_notification' do
      expect(post: '/users/notification_settings/toggle_website_notification').to route_to('notification_settings#toggle_website_notification')
    end

    it 'routes to /users/notification_settings/change_mail_notification' do
      expect(post: '/users/notification_settings/change_mail_notification').to route_to('notification_settings#change_mail_notification')
    end
  end
  describe 'named routes' do
    it 'routes to user_toggle_website_notification_path' do
      expect(post: user_toggle_website_notification_path).to route_to('notification_settings#toggle_website_notification')
    end

    it 'routes to user_change_mail_notification_path' do
      expect(post: user_change_mail_notification_path).to route_to('notification_settings#change_mail_notification')
    end
  end
end
