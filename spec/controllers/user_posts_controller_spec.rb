require 'rails_helper'

RSpec.describe UserPostsController, type: :controller do
  let!(:graetzl) { create :graetzl }

  describe 'GET show' do
    let(:post) { create :user_post, graetzl: graetzl }
    let!(:old_comments) { create_list :comment, 10, commentable: post }
    let!(:new_comments) { create_list :comment, 10, commentable: post }

    context 'when html request' do
      before { get :show, graetzl_id: graetzl, id: post }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'assigns @post' do
        expect(assigns :post).to eq post
      end

      it 'assigns newest @comments' do
        expect(assigns :comments).to match_array new_comments
      end

      it 'renders show.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template(:show)
      end
    end
    context 'when js request for next comments' do
      before { xhr :get, :show, graetzl_id: graetzl, id: post, page: 2 }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'assigns @post' do
        expect(assigns :post).to eq post
      end

      it 'assigns older @comments' do
        expect(assigns :comments).to match_array old_comments
      end

      it 'renders show.js' do
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template(:show)
      end

    end
    context 'when no user_post' do
      let(:post) { create :location_post, graetzl: graetzl }

      it 'raises record not found exception' do
        expect{
          get :show, graetzl_id: graetzl, id: post
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET new' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        get :new, graetzl_id: graetzl
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      let(:user) { create :user }

      before do
        sign_in user
        get :new, graetzl_id: graetzl
      end

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'assigns @user_post for current_user' do
        expect(assigns :user_post).to be_a_new UserPost
        expect(assigns :user_post).to have_attributes(author: user, graetzl: graetzl)
      end

      it 'renders :new' do
        expect(response).to render_template :new
      end
    end
  end

  describe 'POST create' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        post :create, graetzl_id: graetzl, user_post: {}
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      before { sign_in user }

      context 'with valid attributes' do
        let(:params) {{ graetzl_id: graetzl,
          user_post: {
            title: 'something',
            content: 'something else' } }}

        it 'creates new user post record' do
          expect{
            post :create, params
          }.to change{UserPost.count}.by 1
        end

        it 'assigns @graetzl' do
          post :create, params
          expect(assigns :graetzl).to eq graetzl
        end

        it 'assigns @user_post for user' do
          post :create, params
          expect(assigns :user_post).to have_attributes(author: user, graetzl: graetzl)
        end

        it 'redirects to post in graetzl' do
          post :create, params
          expect(response).to redirect_to [graetzl, UserPost.last]
        end
      end
      context 'with invalid attributes' do
        let(:params) {{ graetzl_id: graetzl, user_post: { content: 'something else' } }}

        before { post :create, params }

        it 'renders :new' do
          expect(response).to render_template :new
        end
      end
    end
  end
end
