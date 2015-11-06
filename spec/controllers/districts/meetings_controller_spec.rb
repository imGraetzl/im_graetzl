require 'rails_helper'

RSpec.describe Districts::MeetingsController, type: :controller do

  describe 'GET index' do
    let(:district) { create(:district) }
    let(:graetzl) { create(:graetzl) }
    let!(:cancelled_upcoming) { create(:meeting, graetzl: graetzl, state: Meeting.states[:cancelled]) }
    let(:cancelled_past) { build(:meeting, graetzl: graetzl, state: Meeting.states[:cancelled], starts_at_date: Date.yesterday ) }

    before do
      cancelled_past.save(validate: false)
      get :index, district_id: district
    end

    it 'returns a 200 OK status' do
      expect(response).to be_success
    end

    it 'assigns @district' do
      expect(assigns(:district)).to eq district
    end

    describe 'meetings' do

      it 'has graetzl in scope' do
        expect(district.graetzls).to include graetzl
      end

      it 'assigns @upcoming' do
        expect(assigns(:upcoming)).to be
        expect(assigns(:upcoming)).not_to include(cancelled_past, cancelled_upcoming)
      end

      it 'assigns @past' do
        expect(assigns(:past)).to be
        expect(assigns(:past)).not_to include(cancelled_past, cancelled_upcoming)
      end
    end

    it 'renders /districts/meetings/index' do
      expect(response).to render_template('districts/meetings/index')
    end
  end
end
