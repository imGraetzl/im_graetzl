require 'rails_helper'

RSpec.describe GraetzlsController, type: :routing do
  describe 'routes' do
    it 'routes /graetzl-slug to #show' do
      expect(get: '/graetzl-slug').to route_to('graetzls#show', id: 'graetzl-slug')
    end
  end
  describe 'named routes' do
    it 'routes graetzl_path to #show' do
      expect(get: graetzl_path('graetzl-slug')).to route_to('graetzls#show', id: 'graetzl-slug')
    end
  end
end
