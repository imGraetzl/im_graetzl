require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  let(:user) { create(:user, graetzl: graetzl) }  

  describe 'POST create' do
    context 'when logged out' do

      it 'redirects to login_page' do
        xhr :post, :create, graetzl_id: graetzl.id
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      let(:params) { {
        graetzl_id: graetzl.id,
        post: { content: 'post_content' } }
      }
      before { sign_in user }

      it 'assigns @graetzl' do
        xhr :post, :create, params
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'creates new post' do
        expect {
          xhr :post, :create, params
        }.to change(Post, :count).by(1)
      end

      it 'associates current_user' do
        xhr :post, :create, params
        expect(Post.last.user).to eq user
      end

      it 'assigns @activity' do
        PublicActivity.with_tracking do
          xhr :post, :create, params
        end
        expect(assigns(:activity)).not_to be_nil
      end
    end
  end
end
