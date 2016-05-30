require 'rails_helper'

RSpec.describe Locations::MeetingsController, type: :routing do

  describe 'routes' do
    it 'routes GET locations/location-slug/treffen/new to #new' do
      expect(get: 'locations/location-slug/treffen/new').to route_to 'locations/meetings#new', location_id: 'location-slug'
    end

    it 'routes POST locations/location-slug/treffen to #create' do
      expect(post: 'locations/location-slug/treffen').to route_to 'locations/meetings#create', location_id: 'location-slug'
    end
  end

  describe 'named routes' do
    it 'routes GET new_location_meeting_path to #new' do
      expect(get: new_location_meeting_path('location-slug')).to route_to 'locations/meetings#new', location_id: 'location-slug'
    end

    it 'routes POST location_meetings_path to #new' do
      expect(post: location_meetings_path('location-slug')).to route_to 'locations/meetings#create', location_id: 'location-slug'
    end
  end
end
