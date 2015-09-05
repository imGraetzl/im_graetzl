require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe 'GET show' do
    let(:graetzl) { create(:graetzl) }
    let(:user) { create(:user, graetzl: graetzl) }

    context 'with right graetzl' do
      before { get :show, graetzl_id: graetzl, id: user }
      
      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'assigns @user' do
        expect(assigns(:user)).to eq user
      end

      it 'renders :show' do
        expect(response).to render_template(:show)
      end
    end
    context 'with wrong graetzl' do
      let(:wrong_graetzl) { create(:graetzl) }
      before { get :show, graetzl_id: wrong_graetzl, id: user }
      
      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq wrong_graetzl
      end

      it 'assigns @user' do
        expect(assigns(:user)).to eq user
      end

      it '301 redirects to user in right graetzl' do
        expect(response).to have_http_status(301)
        expect(response).to redirect_to [graetzl, user]
      end
    end
    context 'without graetzl' do
      before { get :show, id: user }

      it 'assigns @graetzl with nil' do
        expect(assigns(:graetzl)).to eq nil
      end

      it 'assigns @user' do
        expect(assigns(:user)).to eq user
      end

      it '301 redirects to user in right graetzl' do
        expect(response).to have_http_status(301)
        expect(response).to redirect_to [graetzl, user]
      end
    end
  end
end
