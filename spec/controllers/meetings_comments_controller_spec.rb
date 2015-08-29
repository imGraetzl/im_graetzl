require 'rails_helper'

RSpec.describe Meetings::CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:meeting) { create(:meeting) }
  let(:form_id_hex) { SecureRandom.hex(4) }

  describe 'POST create' do
    let(:params) {
      {
        comment: { content: 'comment_text' },
        graetzl_id: meeting.graetzl.id,
        meeting_id: meeting.id,
        form_id: form_id_hex
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

      subject(:new_comment) { Comment.last }

      it 'assigns @commentable' do
        xhr :post, :create, params
        expect(assigns(:commentable)).to eq(meeting)
      end

      it 'assigns @commentable of type Meeting' do
        xhr :post, :create, params
        expect(assigns(:commentable).class.name).to eq('Meeting')
      end

      it 'creates new comment' do
        expect {
          xhr :post, :create, params
        }.to change(Comment, :count).by(1)
      end

      it 'sets current_user as user' do
        xhr :post, :create, params
        expect(new_comment.user).to eq(user)
      end

      it 'renders create.js template' do
        xhr :post, :create, params
        expect(response).to render_template('comments/create')
        expect(response.header['Content-Type']).to include('text/javascript')
      end
    end
  end
end
