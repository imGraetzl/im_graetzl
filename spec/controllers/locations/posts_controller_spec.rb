require 'rails_helper'

RSpec.describe Locations::PostsController, type: :controller do
  let!(:location) { create(:location) }

  describe 'POST create' do
    let(:params) {
      { post: { title: 'post-title', content: 'post-content', graetzl_id: location.graetzl.id }, location_id: location }
    }

    context 'when logged out' do
      it 'redirects to login_page' do
        xhr :post, :create, params
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      before { sign_in create(:user) }

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

        it 'assigns @author with location' do
          expect(assigns(:author)).to eq location
        end

        it 'assigns @post' do
          expect(assigns(:post)).to be_truthy
          expect(assigns(:post)).to have_attributes(
            graetzl: location.graetzl,
            title: 'post-title',
            content: 'post-content',
            author: location
          )
        end

        it 'renders locations/posts/create.js' do
          expect(response['Content-Type']).to include('text/javascript')
          expect(response).to render_template('locations/posts/create')
        end
      end
    end
  end
end
