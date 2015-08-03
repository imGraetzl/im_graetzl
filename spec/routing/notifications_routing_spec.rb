require "rails_helper"

RSpec.describe NotificationsController, type: :routing do
  it 'routes to #index' do
    expect(get: '/notifications').to route_to('notifications#index')
  end
end
