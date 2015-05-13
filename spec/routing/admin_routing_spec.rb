require "rails_helper"

RSpec.describe Admin::UsersController, type: :routing do
  describe 'routing' do

    it 'routes /admin to admin/dashboard#index' do
      expect(get: '/admin').to route_to('admin/dashboard#index')
    end

    it 'routes admin_root to admin/dashboard#index' do
      expect(get: admin_root_path).to route_to('admin/dashboard#index')
    end
  end
end