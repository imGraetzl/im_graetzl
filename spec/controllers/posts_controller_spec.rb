require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  let(:user) { create(:user, graetzl: graetzl) }

  describe 'GET show' do
    let!(:post) { create(:post) }

    context 'when logged out' do
      it 'redirects to login_page' do
        get :show, graetzl_id: post.graetzl, id: post
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      before { sign_in create(:user) }

      context 'when html request' do
        before { get :show, graetzl_id: post.graetzl, id: post }

        it 'assigns @post' do
          expect(assigns(:post)).to eq post
        end

        it 'assigns @comments' do
          expect(assigns(:comments)).to be
        end

        it 'renders show.html' do
          expect(response['Content-Type']).to eq 'text/html; charset=utf-8'
          expect(response).to render_template(:show)
        end
      end

      context 'when js request' do
        before { xhr :get, :show, graetzl_id: post.graetzl, id: post }

        it 'assigns @post' do
          expect(assigns(:post)).to eq post
        end

        it 'assigns @comments' do
          expect(assigns(:comments)).to be
        end

        it 'renders show.js' do
          expect(response['Content-Type']).to eq 'text/javascript; charset=utf-8'
          expect(response).to render_template(:show)
        end
      end
    end
  end

  describe 'POST create' do
    context 'when logged out' do
      it 'redirects to login_page' do
        xhr :post, :create
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      let(:params) { {
        post: { graetzl_id: graetzl.id, content: 'post_content' } }
      }
      before { sign_in user }     

      it 'creates new post' do
        expect {
          xhr :post, :create, params
        }.to change(Post, :count).by(1)
      end

      describe 'request' do
        before do
          PublicActivity.with_tracking do
            xhr :post, :create, params
          end
        end
        subject(:new_post) { Post.last }

        it 'associates current_user' do
          expect(new_post.user).to eq user
        end

        it 'associates graetzl' do
          expect(new_post.graetzl).to eq graetzl
        end

        it 'assigns @activity' do
          expect(assigns(:activity)).not_to be_nil
        end

        it 'renders activity partial' do
          expect(response).to render_template(partial: 'public_activity/post/_create')
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:graetzl) { create(:graetzl) }
    let!(:post) { create(:post, graetzl: graetzl) }

    context 'when logged out' do
      context 'when ajax request' do

        it 'redirects to login_page' do
          xhr :delete, :destroy, id: post
          expect(response).to render_template(session[:new])
        end
      end
      context 'when html request' do

        it 'redirects to login_page' do
          delete :destroy, id: post
          expect(response).to render_template(session[:new])
        end
      end
    end
    context 'when logged in' do
      let(:user) { create(:user) }
      before { sign_in user }

      context 'when ajax request' do
        it 'deletes record' do
          expect {
            xhr :delete, :destroy, id: post
          }.to change(Post, :count).by(-1)
        end

        it 'renders empty success response' do
          xhr :delete, :destroy, id: post
          expect(response.body).to be_empty
          expect(response).to have_http_status(:success)
        end
      end
      context 'when html request' do

        it 'deletes post record' do
          expect{
            delete :destroy, id: post
          }.to change{Post.count}.by(-1)
        end

        it 'redirects to graetzl page' do
          delete :destroy, id: post
          expect(response).to redirect_to graetzl
        end
      end
    end
  end
end