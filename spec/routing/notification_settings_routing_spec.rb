require "rails_helper"

RSpec.describe NotificationSettingsController, type: :routing do

    it 'routes to #toggle_website_notification' do
      expect(post: '/users/notification_settings/toggle_website_notification').to route_to('notification_settings#toggle_website_notification')
    end

    it 'routes to #mark as read' do
      expect(post: '/users/notification_settings/mark_as_seen').to route_to('notification_settings#mark_as_seen')
    end
end
