require 'rails_helper'

RSpec.describe MeetingsController, type: :routing do

  describe 'routing treffen' do

    it 'routes GET /graetzl-slug/treffen to #index' do
      expect(get: '/graetzl-slug/treffen').to route_to(
        controller: 'meetings',
        action: 'index',
        graetzl_id: 'graetzl-slug')
    end

    it 'routes GET /graetzl-slug/treffen/meeting-slug to #show' do
      expect(get: '/graetzl-slug/treffen/meeting-slug').to route_to(
        controller: 'meetings',
        action: 'show',
        id: 'meeting-slug',
        graetzl_id: 'graetzl-slug')
    end

    it 'routes GET /treffen/new to #new' do
      expect(get: '/treffen/new').to route_to(
        controller: 'meetings',
        action: 'new')
    end

    it 'routes GET /graetzl-slug/treffen/new to #new' do
      expect(get: '/graetzl-slug/treffen/new').to route_to(
        controller: 'meetings',
        action: 'new',
        graetzl_id: 'graetzl-slug')
    end

    it 'routes POST /treffen to #create' do
      expect(post: '/treffen').to route_to(
        controller: 'meetings',
        action: 'create')
    end

    it 'routes GET /treffen/meeting-slug/edit to #edit' do
      expect(get: '/treffen/meeting-slug/edit').to route_to(
        controller: 'meetings',
        action: 'edit',
        id: 'meeting-slug')
    end

    it 'routes PUT /treffen/meeting-slug to #update' do
      expect(put: '/treffen/meeting-slug').to route_to(
        controller: 'meetings', 
        action: 'update',
        id: 'meeting-slug')
    end

    it 'routes PATCH /treffen/meeting-slug/ to #update' do
      expect(patch: 'treffen/meeting-slug').to route_to(
        controller: 'meetings', 
        action: 'update',
        id: 'meeting-slug')
    end

    it 'routes DELETE /treffen/meeting-slug to #destroy' do
      expect(delete: '/treffen/meeting-slug').to route_to(
        controller: 'meetings',
        action: 'destroy',
        id: 'meeting-slug')
    end
  end  

  describe 'named routing' do

    it 'routes GET graetzl_meetings_path to #index' do
      expect(get: graetzl_meetings_path(graetzl_id: 'graetzl-slug')).to route_to(
        controller: 'meetings',
        action: 'index',
        graetzl_id: 'graetzl-slug')
    end

    it 'routes GET graetzl_meeting_path to #show' do
      expect(get: graetzl_meeting_path(graetzl_id: 'graetzl-slug', id: 'meeting-slug')).to route_to(
        controller: 'meetings',
        action: 'show',
        id: 'meeting-slug',
        graetzl_id: 'graetzl-slug')
    end

    it 'routes GET new_meeting_path to #new' do
      expect(get: new_meeting_path).to route_to(
        controller: 'meetings',
        action: 'new')
    end

    it 'routes GET new_graetzl_meeting_path to #new' do
      expect(get: new_graetzl_meeting_path(graetzl_id: 'graetzl-slug')).to route_to(
        controller: 'meetings',
        action: 'new',
        graetzl_id: 'graetzl-slug')
    end

    it 'routes POST meetings_path to #create' do
      expect(post: meetings_path).to route_to(
        controller: 'meetings',
        action: 'create')
    end

    it 'routes GET edit_meeting_path to #edit' do
      expect(get: edit_meeting_path(id: 'meeting-slug')).to route_to(
        controller: 'meetings',
        action: 'edit',
        id: 'meeting-slug')
    end

    it 'routes PUT meeting_path to #update' do
      expect(put: meeting_path(id: 'meeting-slug')).to route_to(
        controller: 'meetings',
        action: 'update',
        id: 'meeting-slug')
    end

    it 'routes PATCH meeting_path to #update' do
      expect(patch: meeting_path(id: 'meeting-slug')).to route_to(
        controller: 'meetings',
        action: 'update',
        id: 'meeting-slug')
    end

    it 'routes DELETE meeting_path to #destroy' do
      expect(delete: meeting_path(id: 'meeting-slug')).to route_to(
        controller: 'meetings',
        action: 'destroy',
        id: 'meeting-slug')
    end
  end
end