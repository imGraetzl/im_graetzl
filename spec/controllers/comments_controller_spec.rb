require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:commentable_post) { create(:post) }
  let(:form_id_hex) { SecureRandom.hex(4) }

  describe 'POST create' do
    let(:params) {
      {
        comment: { content: 'content_text' },
        commentable_type: commentable_post.class,
        commentable_id: commentable_post.id,
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
        expect(assigns(:commentable)).to eq(commentable_post)
      end

      it 'assigns @form_id' do
        xhr :post, :create, params
        expect(assigns(:form_id)).to eq(form_id_hex)
      end

      it 'creates new comment record' do
        expect {
          xhr :post, :create, params
        }.to change(Comment, :count).by(1)
      end

      it 'sets current_user as user' do
        xhr :post, :create, params
        expect(new_comment.user).to eq(user)
      end
    end
  end
end
