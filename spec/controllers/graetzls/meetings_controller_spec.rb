require 'rails_helper'
require 'controllers/shared/meetings_controller'

RSpec.describe Graetzls::MeetingsController, type: :controller do
  describe 'GET new' do
    let(:graetzl) { create :graetzl }

    context 'when logged out' do
      it 'redirects to login' do
        get :new, graetzl_id: graetzl
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      before do
        sign_in user
        get :new, graetzl_id: graetzl
      end

      it_behaves_like :meetings_new

      it 'assigns @parent with graetzl' do
        expect(assigns :parent).to eq graetzl
      end

      it 'assigns @meeting' do
        expect(assigns :meeting).to have_attributes(
          graetzl_id: graetzl.id,
          location_id: nil)
      end

      it 'assigns @meeting with emtpy address' do
        address = assigns(:meeting).address
        expect(address.street_name).to be_nil
        expect(address.street_number).to be_nil
      end
    end
  end
  describe 'POST create' do
    let(:graetzl) { create :graetzl }

    context 'when logged out' do
      it 'redirects to login' do
        post :create, graetzl_id: graetzl
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      let(:params) {{ graetzl_id: graetzl, meeting: attributes_for(:meeting, graetzl_id: graetzl.id) }}

      before { sign_in user }

      it_behaves_like :meetings_create

      it 'assigns @parent to graetzl' do
        post :create, params
        expect(assigns :parent).to eq graetzl
      end
    end
  end
  describe 'GET show' do
    let(:graetzl) { create :graetzl }
    let(:meeting) { create(:meeting, graetzl: graetzl) }

    context 'when html request' do
      before { get :show, graetzl_id: graetzl, id: meeting }

      it 'assigns @meeting' do
        expect(assigns :meeting).to eq meeting
      end

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'renders show.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template :show
      end

      it 'assigns @comments' do
        expect(assigns :comments).to eq meeting.comments
      end
    end
    context 'when js request' do
      before { xhr :get, :show, graetzl_id: graetzl, id: meeting }

      it 'renders show.js' do
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template :show
      end

      it 'assigns @comments' do
        expect(assigns :comments ).to eq meeting.comments
      end
    end
  end
  describe 'GET index' do
    let(:graetzl) { create :graetzl }

    context 'when html request' do
      before { get :index, graetzl_id: graetzl }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'assigns @map_data' do
        expect(assigns :map_data).to be
      end

      it 'assigns @meetings' do
        expect(assigns :meetings).to be
      end

      it 'renders index.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template(:index)
      end
    end
    context 'when js request' do
      before { xhr :get, :index, graetzl_id: graetzl, page: 2 }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'does not assign @map_data' do
        expect(assigns :map_data).not_to be
      end

      it 'assigns @meetings' do
        expect(assigns :meetings).to be
      end

      it 'renders index.js' do
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template :index
      end
    end
  end
end
