require "rails_helper"

RSpec.describe NotificationsController, type: :routing do
  describe 'routes' do
    it 'routes to GET /notifications to #index' do
      expect(get: '/notifications').to route_to('notifications#index')
    end

    it 'routes POST notifications/mark_as_seen to #mark_as_seen' do
      expect(post: '/notifications/mark_as_seen').to route_to('notifications#mark_as_seen')
    end
  end
  describe 'named routes' do
    it 'routes to GET notifications_path to #index' do
      expect(get: notifications_path).to route_to('notifications#index')
    end

    it 'routes POST mark_as_seen_notifications_path to #mark_as_seen' do
      expect(post: mark_as_seen_notifications_path).to route_to('notifications#mark_as_seen')
    end
  end
end
