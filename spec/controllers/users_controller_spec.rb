require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe 'GET show' do
    let(:graetzl) { create :graetzl }
    let(:user) { create :user, graetzl: graetzl }

    before { create(:district, graetzls: [graetzl]) }

    context 'when logged out' do
      it 'redirects to login with flash' do
        get :show, params: { id: user }
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      before { sign_in create(:user) }

      context 'when html request with without graetzl' do
        it '301 redirects to user in right graetzl' do
          get :show, params: { id: user }
          expect(response).to have_http_status 301
          expect(response).to redirect_to [graetzl, user]
        end
      end
      context 'when html request with wrong graetzl' do
        let!(:other_graetzl) { create :graetzl }

        it '301 redirects to user in right graetzl' do
          get :show, params: { graetzl_id: other_graetzl, id: user }
          expect(response).to have_http_status 301
          expect(response).to redirect_to [graetzl, user]
        end
      end
      context 'when html request with right graetzl' do
        let!(:wall_comments) { create_list :comment, 10, commentable: user }

        before { get :show, params: { graetzl_id: graetzl, id: user } }

        it 'assigns @user' do
          expect(assigns :user).to eq user
        end

        it 'assigns @graetzl' do
          expect(assigns :graetzl).to eq graetzl
        end

        it 'assigns @wall_comments' do
          expect(assigns :wall_comments).to match_array wall_comments
        end

        it 'renders show.html' do
          expect(response.content_type).to eq 'text/html'
          expect(response).to render_template(:show)
        end
      end
    end
  end

  describe 'GET edit' do
    context 'when logged out' do
      it 'redirects to login' do
        get :edit
        expect(response).to redirect_to new_user_session_path
      end
    end
    context 'when logged in' do
      let(:user) { create :user }

      before do
        sign_in user
        get :edit
      end

      it 'assigns @user with current_user' do
        expect(assigns :user).to eq user
      end

      it 'renders edit' do
        expect(response).to render_template :edit
      end
    end
  end

  describe 'PUT update' do
    let(:user) { create :user }

    context 'when logged out' do
      it 'redirects to login' do
        put :update, params: { id: user }
        expect(response).to redirect_to new_user_session_path
      end
    end
    context 'when logged in' do
      before { sign_in user }

      let(:params) { { id: user, user: { email: 'new@email.de' } } }

      it 'updates user record' do
        expect{
          put :update, params: params
          user.reload
        }.to change{user.email}.to 'new@email.de'
      end
      it 'redirect_to to current_user with notice' do
        put :update, params: params
        expect(response).to redirect_to([user.graetzl, user])
        expect(flash[:notice]).to be_present
      end
    end
  end
end
