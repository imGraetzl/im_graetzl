require 'rails_helper'

RSpec.describe Meetings::CommentsController, type: :controller do
  let(:user) { create(:user) }
  let(:meeting) { create(:meeting) }

  describe 'POST create' do
    shared_examples :a_successfull_create_request do

      it 'assigns @commentable' do
        expect(assigns(:commentable)).to eq(meeting)
      end          

      it 'assigns @commentable of type Meeting' do
        expect(assigns(:commentable).class.name).to eq('Meeting')
      end

      describe 'new comment' do
        subject(:new_comment) { Comment.last }

        it 'has commentable meeting' do
          expect(new_comment.commentable).to eq meeting
        end

        it 'has current_user as user' do
          expect(new_comment.user).to eq user
        end
      end
    end

    let(:params) {
      { comment: { content: 'comment_text' }, meeting_id: meeting.id }
    }

    context 'when no current_user' do
      it 'redirects to login_page' do
        xhr :post, :create, params
        expect(response).to render_template(session[:new])
      end
    end

    context 'when current_user' do
      before { sign_in user }

      context 'without inline param' do

        it 'creates new comment' do
          expect {
            xhr :post, :create, params
          }.to change(Comment, :count).by(1)
        end

        describe 'request' do
          render_views
          before { xhr :post, :create, params }

          include_examples :a_successfull_create_request

          it 'renders comment partial' do
            expect(response).to render_template(partial: 'comments/_comment')
          end

          it 'renders stream layout' do
            expect(response.body).to have_selector('div.streamElement')
          end
        end
      end

      context 'with inline param true' do
        before { params.merge!(inline: 'true') }

        it 'creates new comment' do
          expect {
            xhr :post, :create, params
          }.to change(Comment, :count).by(1)
        end

        describe 'request' do
          render_views
          before { xhr :post, :create, params }

          include_examples :a_successfull_create_request

          it 'renders comment partial' do
            expect(response).to render_template(partial: 'comments/_comment')
          end

          it 'does not render stream layout' do
            expect(response.body).not_to have_selector('div.streamElement')
          end
        end
      end
    end
  end
end
