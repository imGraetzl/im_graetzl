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

  end
end
