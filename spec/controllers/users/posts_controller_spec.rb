require 'rails_helper'

RSpec.describe Users::PostsController, type: :controller do
  let!(:user) { create(:user) }
  let!(:graetzl) { create(:graetzl) }

  describe 'POST create' do
    let(:params) {
      { post: { content: 'post-content', graetzl_id: graetzl.id }, user_id: user }
    }

    context 'when logged out' do
      it 'redirects to login_page' do
        xhr :post, :create, params
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      before { sign_in user }

      it 'creates new comment' do
        expect {
          xhr :post, :create, params
        }.to change(Post, :count).by(1)
      end

      it 'creates new activity record', job: true do
        expect {
          xhr :post, :create, params
        }.to change(Activity, :count).by(1)
      end

      describe 'request' do
        before { xhr :post, :create, params }

        it 'assigns @author with user' do
          expect(assigns(:author)).to eq user
        end

        it 'assigns @post' do
          expect(assigns(:post)).to be_truthy
          expect(assigns(:post)).to have_attributes(
            graetzl: graetzl,
            title: nil,
            content: 'post-content',
            author: user
          )
        end

        it 'renders locations/posts/create.js' do
          expect(response['Content-Type']).to include('text/javascript')
          expect(response).to render_template('posts/create')
        end
      end
    end
  end
end
