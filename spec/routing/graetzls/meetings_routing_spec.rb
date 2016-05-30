require 'rails_helper'

RSpec.describe Graetzls::MeetingsController, type: :routing do
  describe 'routes' do
    it 'routes GET graetzl-slug/treffen/new to #new' do
      expect(get: 'graetzl-slug/treffen/new').to route_to 'graetzls/meetings#new', graetzl_id: 'graetzl-slug'
    end

    it 'routes POST graetzl-slug/treffen to #create' do
      expect(post: 'graetzl-slug/treffen').to route_to 'graetzls/meetings#create', graetzl_id: 'graetzl-slug'
    end
  end

  describe 'named routes' do
    it 'routes GET new_graetzl_meeting_path to #new' do
      expect(get: new_graetzl_meeting_path('graetzl-slug')).to route_to 'graetzls/meetings#new', graetzl_id: 'graetzl-slug'
    end

    it 'routes POST graetzl_meetings_path to #new' do
      expect(post: graetzl_meetings_path('graetzl-slug')).to route_to 'graetzls/meetings#create', graetzl_id: 'graetzl-slug'
    end
  end
end
