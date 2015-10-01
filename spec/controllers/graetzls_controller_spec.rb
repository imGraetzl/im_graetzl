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

    describe '@meetings' do
      context 'with upcoming meetings' do
        before do
          3.times{ create(:meeting, graetzl: graetzl, starts_at_date: Date.tomorrow) }
          get :show, id: graetzl
        end

        it 'assigns 2 upcoming meetings' do
          expect(assigns(:meetings).count).to eq 2
        end
      end
      context 'without upcoming meetings' do
        before do
          3.times do
            meeting = build(:meeting, graetzl: graetzl, starts_at_date: Date.yesterday)
            meeting.save(validate: false)
          end
          get :show, id: graetzl
        end

        it 'returns empty collection' do
          expect(assigns(:meetings)).to be_empty
        end
      end
    end

    describe '@locations' do
      context 'with approved locations' do
        before do
          3.times{ create(:location, graetzl: graetzl, state: Location.states[:approved]) }
          get :show, id: graetzl
        end

        it 'assigns 2 locations' do
          expect(assigns(:locations).count).to eq 2
        end
      end
      context 'without approved locations' do
        before do
          3.times{ create(:location, graetzl: graetzl) }
          get :show, id: graetzl
        end

        it 'is empty' do          
          expect(assigns(:locations)).to be_empty
        end
      end
    end
  end
end
