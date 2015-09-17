require 'rails_helper'
require 'controllers/shared/commentable'

RSpec.describe Posts::CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:commentable_post) { create(:post) }

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