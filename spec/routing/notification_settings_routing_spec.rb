require "rails_helper"

RSpec.describe NotificationSettingsController, type: :routing do
    it 'routes to #index' do
      expect(get: '/users/notification_settings').to route_to('notification_settings#index')
    end
end
