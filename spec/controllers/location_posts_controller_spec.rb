require 'rails_helper'

RSpec.describe LocationPostsController, type: :controller do
  describe 'POST create' do
    let(:graetzl) { create :graetzl }
    let(:location) { create :location, :approved, graetzl: graetzl }

    context 'when logged out' do
      it 'returns 401 unauthorized' do
        xhr :post, :create, location_post: {}
        expect(response).to have_http_status 401
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      let(:params) {{ location_post: {
          title: 'something',
          content: 'something else',
          graetzl_id: graetzl.id,
          author_id: location.id,
          author_type: 'Location' } }}

      before { sign_in user }

      it 'creates new location_post record' do
        expect{
          xhr :post, :create, params
        }.to change{LocationPost.count}.by 1
      end

      it 'logs activity' do
        expect{
          xhr :post, :create, params
        }.to change{Activity.count}.by 1
      end

      it 'assigns @location_post with attributes' do
        xhr :post, :create, params
        expect(assigns :location_post).to have_attributes(author: location, graetzl: graetzl)
      end

      it 'renders create.js' do
        xhr :post, :create, params
        expect(response).to render_template :create
      end
    end
  end
end
