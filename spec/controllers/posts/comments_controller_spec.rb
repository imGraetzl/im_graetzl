require 'rails_helper'
require 'controllers/shared/commentable'

RSpec.describe Posts::CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:commentable_post) { create(:post) }

  describe 'GET index' do
    let!(:comments) { create_list(:comment, 10, commentable: commentable_post) }
    before do
      sign_in user
      xhr :get, :index, post_id: commentable_post
    end

    it 'assigns @commentable' do
      expect(assigns :commentable).to eq commentable_post
    end

    it 'assigns @comments with inline = true' do
      expect(assigns(:comments).to_a).to match_array comments
      expect(assigns(:comments).map(&:inline)).to all(be_truthy)
    end

    it 'renders index.js' do
      expect(response.content_type).to eq 'text/javascript'
      expect(response).to render_template(:index)
    end
  end

  describe 'POST create' do
    let(:params) {
      { comment: { content: 'comment_text' }, post_id: commentable_post }
    }

    context 'when logged out' do
      it 'redirects to login_page' do
        xhr :post, :create, params
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      before { sign_in user }

      context 'without inline param' do
        include_examples :stream_comment do
          let(:resource) { commentable_post }
        end
      end

      context 'with inline param true' do
        include_examples :inline_comment do
          let(:resource) { commentable_post }
        end
      end
    end
  end
end
