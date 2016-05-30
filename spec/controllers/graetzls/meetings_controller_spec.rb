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

      it 'assigns @parent with graetzl' do
        expect(assigns :parent).to eq graetzl
      end

      it 'assigns @meeting without adddress' do
        expect(assigns :meeting).to have_attributes(
          graetzl_id: graetzl.id,
          location_id: nil,
          address: nil)
      end

      it_behaves_like :meetings_new
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

      it 'assigns new @meeting' do
        post :create, params
        expect(assigns :meeting).to be_a Meeting
      end
    end
  end
end
