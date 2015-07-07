require "rails_helper"

RSpec.describe NotificationSettingsController, type: :routing do
    it 'routes to #index' do
      expect(get: '/users/notification_settings').to route_to('notification_settings#index')
    end

    it 'routes to #toggle_website_notification' do
      expect(post: '/users/notification_settings/toggle_website_notification').to route_to('notification_settings#toggle_website_notification')
    end
end
