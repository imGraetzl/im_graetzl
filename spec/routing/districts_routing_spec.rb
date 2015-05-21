require "rails_helper"

RSpec.describe DistrictsController, type: :routing do
  
  describe 'routing with wien' do

    it 'routes /wien to #index' do
      expect(get: '/wien').to route_to('districts#index')
    end

    it 'routes /:district_id to #show' do
      expect(get: 'wien/1').to route_to('districts#show', id: '1')
    end

    it 'routes /district_long_name to #show' do
      expect(get: 'wien/district_long_name').to route_to('districts#show', id: 'district_long_name')
    end
  end


  describe 'named route helpers' do

    it 'routes to #index' do
      expect(get: districts_path).to route_to('districts#index')
    end

    it 'routes to #show' do
      expect(get: district_path('district_long_name')).to route_to('districts#show', id: 'district_long_name')
    end
  end
end