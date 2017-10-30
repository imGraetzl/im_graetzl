require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:graetzl) { create :graetzl }

  describe 'GET index' do
    let!(:old_user_posts) { create_list :user_post, 15, graetzl: graetzl }
    let!(:new_user_posts) { create_list :user_post, 14, graetzl: graetzl }
    let!(:admin_post) { create :admin_post }
    before { create :operating_range, operator: admin_post, graetzl: graetzl }

    context 'when js request' do
      before { get :index, params: { graetzl_id: graetzl, page: 2 }, xhr: true }

      it 'assigns older @posts' do
        expect(assigns :posts).to match_array old_user_posts
      end

      it 'renders index.js' do
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template :index
      end
    end

    describe 'DELETE destroy' do
      let!(:post) { create :user_post, graetzl: graetzl }

      context 'when logged out' do
        it 'redirects to login with flash' do
          delete :destroy, params: { id: post }
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
              delete :destroy, params: { id: post }
            }.to change{Post.count}.by -1
          end

          it 'redirects to graetzl' do
            delete :destroy, params: { id: post }
            expect(response).to redirect_to graetzl
          end
        end
        context 'when js request' do
          it 'deletes record' do
            expect{
              delete :destroy, params: { id: post }, xhr: true
            }.to change{Post.count}.by -1
          end

          it 'render destroy.js' do
            delete :destroy, params: { id: post }, xhr: true
            expect(response).to render_template :destroy
          end
        end
      end
    end
  end
end
