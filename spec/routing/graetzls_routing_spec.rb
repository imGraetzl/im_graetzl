require 'rails_helper'

RSpec.describe GraetzlsController, type: :routing do

  describe 'routing' do

    it 'routes /:graetzl_id to #show' do
      expect(get: '/1').to route_to('graetzls#show', id: '1')
    end

    it 'routes /graetzl_name to #show' do
      expect(get: '/graetzl_name').to route_to('graetzls#show', id: 'graetzl_name')
    end
  end


  describe 'named route helpers' do

    it 'routes to #show' do
      expect(get: graetzl_path('graetzl_name')).to route_to('graetzls#show', id: 'graetzl_name')
    end

    it 'routes to #show (with numeric id)' do
      expect(get: graetzl_path(1)).to route_to('graetzls#show', id: '1')
    end
  end
end
