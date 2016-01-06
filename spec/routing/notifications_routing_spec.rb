require "rails_helper"

RSpec.describe NotificationsController, type: :routing do
  it 'routes to GET /notifications to notifications#index' do
    expect(get: '/notifications').to route_to('notifications#index')
  end

  it 'routes POST notifications/mark_as_seen to notifications#mark_as_seen' do
    expect(post: '/notifications/mark_as_seen').to route_to('notifications#mark_as_seen')
  end

  it 'routes GET notifications/paginate to notifications#paginate' do
    expect(get: '/notifications/paginate').to route_to('notifications#paginate')
  end
end
