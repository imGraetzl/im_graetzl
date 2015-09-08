require 'rails_helper'
require 'controllers/shared/commentable'

RSpec.describe Users::CommentsController, type: :controller do
  let(:commentable_user) { create(:user) }

  describe 'POST create' do
    let(:params) {
      { comment: { content: 'comment_text' }, user_id: commentable_user }
    }

    context 'when logged out' do
      it 'redirects to login_page' do
        xhr :post, :create, params
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      let(:user) { create(:user) }
      before { sign_in user }

      describe 'comment on other wall' do
        context 'without inline param' do

          include_examples :stream_comment do
            let(:resource) { commentable_user }
          end
        end
        context 'with inline param true' do

          include_examples :inline_comment do
            let(:resource) { commentable_user }
          end
        end
      end
      describe 'comment on own wall' do
        render_views
        before { params.merge!(user_id: user) }

        it 'creates new comment' do
          expect {
            xhr :post, :create, params
          }.to change(Comment, :count).by(1)
        end

        it 'does not create activity record' do
          expect {
            PublicActivity.with_tracking { xhr :post, :create, params }
          }.not_to change{PublicActivity::Activity.count}
        end

        describe 'request' do
          before { PublicActivity.with_tracking { xhr :post, :create, params } }

          it 'assigns @commentable' do
            expect(assigns(:commentable)).to eq(user)
          end

          it 'renders comment partial' do
            expect(response).to render_template(partial: 'comments/_comment')
          end
          describe 'new comment' do
            subject(:new_comment) { Comment.last }

            it 'has user as commentable' do
              expect(new_comment.commentable).to eq user
            end

            it 'has current_user as user' do
              expect(new_comment.user).to eq user
            end
          end
        end
        context 'without inline param' do

          it 'renders stream layout' do
            xhr :post, :create, params
            expect(response.body).to have_selector('div.streamElement')
          end
        end
        context 'with inline param true' do

          it 'does not render stream layout' do
            xhr :post, :create, params
            expect(response.body).to have_selector('div.streamElement')
          end          
        end
      end
    end
  end
end
