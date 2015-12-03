require 'rails_helper'

RSpec.describe Districts::MeetingsController, type: :controller do

  describe 'GET index' do
    let(:district) { create(:district) }

    context 'when html request' do
      let(:graetzl) { create(:graetzl) }
      let!(:cancelled_upcoming) { create(:meeting, graetzl: graetzl, state: Meeting.states[:cancelled]) }
      let(:cancelled_past) { create(:meeting_skip_validate, graetzl: graetzl, state: Meeting.states[:cancelled], starts_at_date: Date.yesterday ) }

      before { get :index, district_id: district }

      it 'assigns @district' do
        expect(assigns(:district)).to eq district
      end

      it 'assigns @upcoming' do
        expect(assigns(:upcoming)).to be
        expect(assigns(:upcoming)).not_to include(cancelled_past, cancelled_upcoming)
      end

      it 'assigns @past' do
        expect(assigns(:past)).to be
        expect(assigns(:past)).not_to include(cancelled_past, cancelled_upcoming)
      end

      it 'renders /districts/meetings/index.html' do
        expect(response['Content-Type']).to eq 'text/html; charset=utf-8'
        expect(response).to render_template('districts/meetings/index')
      end
    end

    context 'when js request' do
      before { xhr :get, :index, { district_id: district, scope: :upcoming } }

      it 'assigns @scope' do
        expect(assigns(:scope)).to eq :upcoming
      end

      it 'assigns @meetings' do
        expect(assigns(:meetings)).to be
      end

      it 'does not assign @map_data' do
        expect(assigns(:map_data)).not_to be
      end

      it 'renders /districts/meetings/index.js' do
        expect(response.header['Content-Type']).to include('text/javascript')
        expect(response).to render_template('districts/meetings/index')
      end
    end
  end
end
