require "rails_helper"

RSpec.describe MeetingsController, type: :routing do
  describe "routing with 'treffen'" do

    it 'routes to #show' do
      expect(get: '/graetzl_slug/treffen/meeting_slug').to route_to('meetings#show', id: 'meeting_slug', graetzl_id: 'graetzl_slug')
    end

    it 'routes to #new' do
      expect(get: '/graetzl_slug/treffen/new').to route_to('meetings#new', graetzl_id: 'graetzl_slug')
    end

    it 'routes to #create' do
      expect(post: '/1/treffen').to route_to('meetings#create', graetzl_id: '1')
    end

    it 'routes to #create (with numeric id)' do
      expect(post: '/slug/treffen').to route_to('meetings#create', graetzl_id: 'slug')
    end
  end

  describe "named routing with 'meeting'" do

    it 'routes to #show' do
      expect(get: graetzl_meeting_path(graetzl_id: 'graetzl_slug', id: 'meeting_slug')).to route_to('meetings#show', id: 'meeting_slug', graetzl_id: 'graetzl_slug')
    end

    it 'routes to #new' do
      expect(get: new_graetzl_meeting_path(graetzl_id: 'graetzl_slug')).to route_to('meetings#new', graetzl_id: 'graetzl_slug')
    end

    it 'routes to #create' do
      expect(post: graetzl_meetings_path(graetzl_id: 'graetzl_slug')).to route_to('meetings#create', graetzl_id: 'graetzl_slug')
    end

    it 'routes to #create (with numeric id)' do
      expect(post: graetzl_meetings_path(graetzl_id: 1)).to route_to('meetings#create', graetzl_id: '1')
    end
  end
end