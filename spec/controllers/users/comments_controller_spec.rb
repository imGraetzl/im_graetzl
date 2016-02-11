require 'rails_helper'

RSpec.describe Users::CommentsController, type: :controller do

  describe 'POST create' do
    let(:commentable_user) { create(:user) }
    let(:params) { { comment: { content: 'comment-content'}, user_id: commentable_user } }

    context 'when logged out' do
      it 'redirects to login' do
        xhr :post, :create, params
        expect(response).to render_template(session[:new])
      end
    end

    context 'comment on other wall' do
      let(:user) { create(:user) }
      before { sign_in user }

      it 'creates new comment record' do
        expect {
          xhr :post, :create, params
        }.to change(Comment, :count).by(1)
      end

      it 'creates new activity record' do
        expect {
          PublicActivity.with_tracking { xhr :post, :create, params }
        }.to change(PublicActivity::Activity, :count).by(1)
      end

      describe 'request' do
        before { xhr :post, :create, params }

        it 'assigns @commentable' do
          expect(assigns(:commentable)).to eq commentable_user
        end

        it 'assigns @comment' do
          expect(assigns(:comment)).to be_truthy
          expect(assigns(:comment)).to have_attributes(
            user: user,
            commentable: commentable_user,
            content: 'comment-content')
        end

        it 'renders create.js' do
          expect(response['Content-Type']).to include('text/javascript')
          expect(response).to render_template('comments/create')
        end
      end
    end

    context 'comment on own wall' do
      before { sign_in commentable_user }

      it 'creates new comment record' do
        expect {
          xhr :post, :create, params
        }.to change(Comment, :count).by(1)
      end

      it 'does not create new activity record' do
        expect {
          PublicActivity.with_tracking { xhr :post, :create, params }
        }.not_to change(PublicActivity::Activity, :count)
      end

      describe 'request' do
        before { xhr :post, :create, params }

        it 'assigns @commentable' do
          expect(assigns(:commentable)).to eq commentable_user
        end

        it 'assigns @comment' do
          expect(assigns(:comment)).to be_truthy
          expect(assigns(:comment)).to have_attributes(
            user: commentable_user,
            commentable: commentable_user,
            content: 'comment-content')
        end

        it 'renders create.js' do
          expect(response['Content-Type']).to include('text/javascript')
          expect(response).to render_template('comments/create')
        end
      end
    end
  end
end
