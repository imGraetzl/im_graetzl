require 'rails_helper'

RSpec.describe GraetzlsController, type: :controller do
  let(:user) { create(:user) }
  let(:graetzl) { create(:graetzl) }

  describe 'GET index' do
    before { get :index }

    it 'returns a 200 status' do
      expect(response).to be_success
    end

    it 'assigns @graetzls' do
      expect(assigns(:graetzls)).to eq Graetzl.all
    end

    it 'renders index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET show' do
    before { get :show, id: graetzl }

    it 'returns a 200 status' do
      expect(response).to be_success
    end

    it 'renders show' do
      expect(response).to render_template(:show)
    end

    it 'assigns @graetzl' do
      expect(assigns(:graetzl)).to eq graetzl
    end

    it 'assigns @activities' do
      expect(assigns(:activities)).to be_a_kind_of(Array)
      expect(assigns(:activities)).to eq graetzl.activity
    end

    it 'assigns @map_data' do
      expect(assigns(:map_data)).to be_truthy
    end

    describe '@meeting' do
      let!(:meeting) { create(:meeting, graetzl: graetzl, starts_at_date: Date.tomorrow) }

      context 'with upcoming meetings' do
        before { get :show, id: graetzl }

        it 'assigns next meeting' do
          expect(assigns(:meeting)).to eq meeting
        end
      end
      context 'without upcoming meetings' do
        before do
          meeting.starts_at_date = Date.yesterday
          meeting.save(validate: false)
          get :show, id: graetzl
        end

        it 'assigns nil' do
          expect(assigns(:meeting)).to eq nil
        end
      end
    end

    describe '@locations' do
      context 'with managed locations' do
        let!(:location_1) { create(:location_managed, graetzl: graetzl) }
        before { get :show, id: graetzl }

        it 'contains locations' do
          expect(assigns(:locations)).to include(location_1)
        end
      end
      context 'without managed locations' do
        before { get :show, id: graetzl }

        it 'is empty' do
          expect(assigns(:locations)).to be_empty
        end
      end
    end
  end
end
