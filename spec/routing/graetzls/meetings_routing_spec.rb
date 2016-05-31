require 'rails_helper'

RSpec.describe Graetzls::MeetingsController, type: :routing do
  describe 'routes' do
    it 'routes GET graetzl-slug/treffen to #index' do
      expect(get: 'graetzl-slug/treffen').to route_to 'graetzls/meetings#index', graetzl_id: 'graetzl-slug'
    end

    it 'routes GET graetzl-slug/treffen/meeting-slug to #show' do
      expect(get: 'graetzl-slug/treffen/meeting-slug').to route_to('graetzls/meetings#show', id: 'meeting-slug', graetzl_id: 'graetzl-slug')
    end
    it 'routes GET graetzl-slug/treffen/new to #new' do
      expect(get: 'graetzl-slug/treffen/new').to route_to 'graetzls/meetings#new', graetzl_id: 'graetzl-slug'
    end

    it 'routes POST graetzl-slug/treffen to #create' do
      expect(post: 'graetzl-slug/treffen').to route_to 'graetzls/meetings#create', graetzl_id: 'graetzl-slug'
    end
  end

  describe 'named routes' do
    it 'routes GET graetzl_meetings_path to #index' do
      expect(get: graetzl_meetings_path('graetzl-slug')).to route_to 'graetzls/meetings#index', graetzl_id: 'graetzl-slug'
    end

    it 'routes GET graetzl_meeting_path to #show' do
      expect(get: graetzl_meeting_path('graetzl-slug', 'meeting-slug')).to route_to 'graetzls/meetings#show', id: 'meeting-slug', graetzl_id: 'graetzl-slug'
    end
    it 'routes GET new_graetzl_meeting_path to #new' do
      expect(get: new_graetzl_meeting_path('graetzl-slug')).to route_to 'graetzls/meetings#new', graetzl_id: 'graetzl-slug'
    end

    it 'routes POST graetzl_meetings_path to #create' do
      expect(post: graetzl_meetings_path('graetzl-slug')).to route_to 'graetzls/meetings#create', graetzl_id: 'graetzl-slug'
    end
  end
end
