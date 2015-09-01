require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  let(:user) { create(:user, graetzl: graetzl) }  

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
end
