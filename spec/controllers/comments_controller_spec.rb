require 'rails_helper'

RSpec.describe CommentsController, type: :controller do

  describe 'PUT update' do
    let(:user) { create(:user) }
    let(:comment) { create(:comment, user: user) }

    context 'when logged in' do
      before { sign_in user }

      context 'with valid params' do
        before { xhr :put, :update, { id: comment.id, content: 'new content' } }

        it 'assigns @comment' do
          expect(assigns(:comment)).to eq comment
        end

        it 'updates content' do
          expect(comment.reload.content). to eq 'new content'
        end

        it 'renders new content as text' do
          expect(response.body).to eq 'new content'
        end
      end

      context 'with invalid params' do
        before { xhr :put, :update, { id: comment.id, content: '' } }

        it 'assigns @comment' do
          expect(assigns(:comment)).to eq comment
        end

        it 'does not update content' do
          previous = comment.content
          expect(comment.reload.content). to eq previous
        end

        it 'renders excuse text' do
          expect(response.body).to eq 'Es gab ein Problem...'
        end
      end
    end
  end
end
