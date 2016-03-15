require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:graetzl) { create :graetzl }

  describe 'GET index' do
    let!(:old_user_posts) { create_list :user_post, 15, graetzl: graetzl }
    let!(:new_user_posts) { create_list :user_post, 15, graetzl: graetzl }

    context 'when html request' do
      before { get :index, graetzl_id: graetzl }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'assigns @map_data' do
        expect(assigns :map_data).to be
      end

      it 'assigns newest @posts' do
        expect(assigns :posts).to match_array new_user_posts
      end

      it 'renders index.html' do
        expect(response['Content-Type']).to eq 'text/html; charset=utf-8'
        expect(response).to render_template :index
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

      it 'assigns older @posts' do
        expect(assigns :posts).to match_array old_user_posts
      end

      it 'renders index.js' do
        expect(response['Content-Type']).to eq 'text/javascript; charset=utf-8'
        expect(response).to render_template :index
      end
    end

    describe 'DELETE destroy' do
      let!(:post) { create :user_post, graetzl: graetzl }

      context 'when logged out' do
        it 'redirects to login with flash' do
          delete :destroy, id: post
          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to be_present
        end
      end
      context 'when logged in' do
        let(:user) { create :user }
        before { sign_in user }

        context 'when html request' do
          it 'deletes record' do
            expect{
              delete :destroy, id: post
            }.to change{Post.count}.by -1
          end

          it 'redirects to graetzl' do
            delete :destroy, id: post
            expect(response).to redirect_to graetzl
          end
        end
        context 'when js request' do
          it 'deletes record' do
            expect{
              xhr :delete, :destroy, id: post
            }.to change{Post.count}.by -1
          end

          it 'render destroy.js' do
            xhr :delete, :destroy, id: post
            expect(response).to render_template :destroy
          end
        end
      end
    end
  end
end
