require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }

  describe 'POST create' do
    let(:params) {
      {
        comment: { content: 'content_text' }
      }
    }

    context 'when no current_user' do
      it 'redirects to login_page' do
        xhr :post, :create, params
        expect(response).to render_template(session[:new])
      end
    end

    context 'when current_user' do
      before { sign_in user }
    end
  end
end
