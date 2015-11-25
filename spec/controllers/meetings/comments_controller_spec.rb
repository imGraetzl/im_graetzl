require 'rails_helper'
require 'controllers/shared/commentable'

RSpec.describe Meetings::CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:meeting) { create(:meeting) }

  describe 'POST create' do
    let(:params) {
      { comment: { content: 'comment_text' }, meeting_id: meeting }
    }

    context 'when logged out' do
      it 'redirects to login_page' do
        xhr :post, :create, params
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      before { sign_in user }

      context 'with inline false' do
        include_examples :stream_comment do
          let(:resource) { meeting }
        end
      end

      context 'with inline param true' do
        include_examples :inline_comment do
          let(:resource) { meeting }
        end
      end
    end
  end
end
