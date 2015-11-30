require 'rails_helper'

RSpec.describe CommentsController, type: :controller do

  describe 'DELETE destroy' do
    let(:user) { create(:user) }
    let!(:comment) { create(:comment, user: user) }
    before { sign_in user }

    it 'deletes comment record' do
      expect{
        xhr :delete, :destroy, id: comment.id
      }.to change(Comment, :count).by(-1)
    end

    describe 'request' do
      before { xhr :delete, :destroy, id: comment.id }

      it 'assigns @comment' do
        expect(assigns(:comment)).to eq comment
      end

      it 'assigns @element_id' do
        expect(assigns(:element_id)).to eq "comment_#{comment.id}"
      end

      it 'renders destroy.js' do
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template(:destroy)
      end
    end
  end
end
