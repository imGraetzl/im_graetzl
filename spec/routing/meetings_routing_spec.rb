require 'rails_helper'

RSpec.describe MeetingsController, type: :routing do
  describe 'routes' do
    it 'routes GET /graetzl-slug/treffen to #index' do
      expect(get: '/graetzl-slug/treffen').to route_to('meetings#index', graetzl_id: 'graetzl-slug')
    end

    it 'routes GET /graetzl-slug/treffen/meeting-slug to #show' do
      expect(get: '/graetzl-slug/treffen/meeting-slug').to route_to('meetings#show', id: 'meeting-slug', graetzl_id: 'graetzl-slug')
    end

    it 'routes GET /treffen/new to #new' do
      expect(get: '/treffen/new').to route_to('meetings#new')
    end

    it 'routes GET /graetzl-slug/treffen/new to #new' do
      expect(get: '/graetzl-slug/treffen/new').to route_to('meetings#new', graetzl_id: 'graetzl-slug')
    end

    it 'routes POST /treffen to #create' do
      expect(post: '/treffen').to route_to('meetings#create')
    end

    it 'routes GET /treffen/meeting-slug/edit to #edit' do
      expect(get: '/treffen/meeting-slug/edit').to route_to('meetings#edit', id: 'meeting-slug')
    end

    it 'routes PUT /treffen/meeting-slug to #update' do
      expect(put: '/treffen/meeting-slug').to route_to('meetings#update', id: 'meeting-slug')
    end

    it 'routes DELETE /treffen/meeting-slug to #destroy' do
      expect(delete: '/treffen/meeting-slug').to route_to('meetings#destroy', id: 'meeting-slug')
    end
  end
  describe 'named routes' do
    it 'routes GET graetzl_meetings_path to #index' do
      expect(get: graetzl_meetings_path('graetzl-slug')).to route_to('meetings#index', graetzl_id: 'graetzl-slug')
    end

    it 'routes GET graetzl_meeting_path to #show' do
      expect(get: graetzl_meeting_path('graetzl-slug', 'meeting-slug')).to route_to('meetings#show', id: 'meeting-slug', graetzl_id: 'graetzl-slug')
    end

    it 'routes GET new_meeting_path to #new' do
      expect(get: new_meeting_path).to route_to('meetings#new')
    end

    it 'routes GET new_graetzl_meeting_path to #new' do
      expect(get: new_graetzl_meeting_path('graetzl-slug')).to route_to('meetings#new', graetzl_id: 'graetzl-slug')
    end

    it 'routes POST meetings_path to #create' do
      expect(post: meetings_path).to route_to('meetings#create')
    end

    it 'routes GET edit_meeting_path to #edit' do
      expect(get: edit_meeting_path('meeting-slug')).to route_to('meetings#edit', id: 'meeting-slug')
    end

    it 'routes PUT meeting_path to #update' do
      expect(put: meeting_path('meeting-slug')).to route_to('meetings#update', id: 'meeting-slug')
    end

    it 'routes DELETE meeting_path to #destroy' do
      expect(delete: meeting_path('meeting-slug')).to route_to('meetings#destroy', id: 'meeting-slug')
    end
  end
end
