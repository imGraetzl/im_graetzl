require 'rails_helper'

RSpec.describe MeetingsController, type: :routing do

  describe 'routing with treffen' do

    it 'routes GET /treffen to #index' do
      expect(get: '/graetzl_slug/treffen').to route_to(
        controller: 'meetings',
        action: 'index',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes GET /treffen/meeting_slug to #show' do
      expect(get: '/graetzl_slug/treffen/meeting_slug').to route_to(
        controller: 'meetings',
        action: 'show',
        id: 'meeting_slug',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes GET /treffen/new to #new' do
      expect(get: '/graetzl_slug/treffen/new').to route_to(
        controller: 'meetings',
        action: 'new',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes POST /treffen/new to #create' do
      expect(post: '/graetzl_slug/treffen').to route_to(
        controller: 'meetings',
        action: 'create',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes GET /treffen/meeting_slug/edit to #edit' do
      expect(get: '/graetzl_slug/treffen/meeting_slug/edit').to route_to(
        controller: 'meetings',
        action: 'edit',
        graetzl_id: 'graetzl_slug',
        id: 'meeting_slug')
    end

    it 'routes PUT /treffen/meeting_slug to #update' do
      expect(put: '/graetzl_slug/treffen/meeting_slug').to route_to(
        controller: 'meetings', 
        action: 'update',
        graetzl_id: 'graetzl_slug',
        id: 'meeting_slug')
    end

    it 'routes PATCH /treffen/meeting_slug/ to #update' do
      expect(patch: '/graetzl_slug/treffen/meeting_slug').to route_to(
        controller: 'meetings', 
        action: 'update',
        graetzl_id: 'graetzl_slug',
        id: 'meeting_slug')
    end

    it 'routes DELETE /treffen/meeting_slug to #destroy' do
      expect(delete: '/graetzl_slug/treffen/meeting_slug').to route_to(
        controller: 'meetings',
        action: 'destroy',
        graetzl_id: 'graetzl_slug',
        id: 'meeting_slug')
    end
  end
  

  describe 'named route helpers' do

    it 'routes GET graetzl_meetings_path to #index' do
      expect(get: graetzl_meetings_path(graetzl_id: 'graetzl_slug')).to route_to(
        controller: 'meetings',
        action: 'index',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes GET graetzl_meeting_path to #show' do
      expect(get: graetzl_meeting_path(graetzl_id: 'graetzl_slug', id: 'meeting_slug')).to route_to(
        controller: 'meetings',
        action: 'show',
        id: 'meeting_slug',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes GET new_graetzl_meeting_path to #new' do
      expect(get: new_graetzl_meeting_path(graetzl_id: 'graetzl_slug')).to route_to(
        controller: 'meetings',
        action: 'new',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes POST graetzl_meetings_path to #create' do
      expect(post: graetzl_meetings_path(graetzl_id: 'graetzl_slug')).to route_to(
        controller: 'meetings',
        action: 'create',
        graetzl_id: 'graetzl_slug')
    end

    it 'routes GET edit_graetzl_meeting_path to #edit' do
      expect(get: edit_graetzl_meeting_path(graetzl_id: 'graetzl_slug', id: 'meeting_slug')).to route_to(
        controller: 'meetings',
        action: 'edit',
        graetzl_id: 'graetzl_slug',
        id: 'meeting_slug')
    end

    it 'routes PUT graetzl_meeting_path to #update' do
      expect(put: graetzl_meeting_path(graetzl_id: 'graetzl_slug', id: 'meeting_slug')).to route_to(
        controller: 'meetings',
        action: 'update',
        graetzl_id: 'graetzl_slug',
        id: 'meeting_slug')
    end

    it 'routes PATCH graetzl_meeting_path to #update' do
      expect(patch: graetzl_meeting_path(graetzl_id: 'graetzl_slug', id: 'meeting_slug')).to route_to(
        controller: 'meetings',
        action: 'update',
        graetzl_id: 'graetzl_slug',
        id: 'meeting_slug')
    end

    it 'routes DELETE graetzl_meeting_path to #destroy' do
      expect(delete: graetzl_meeting_path(graetzl_id: 'graetzl_slug', id: 'meeting_slug')).to route_to(
        controller: 'meetings',
        action: 'destroy',
        graetzl_id: 'graetzl_slug',
        id: 'meeting_slug')
    end
  end
end