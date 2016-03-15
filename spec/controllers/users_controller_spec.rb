require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe 'GET show' do
    let(:graetzl) { create :graetzl }
    let(:user) { create :user, graetzl: graetzl }

    before { create :district }

    context 'when logged out' do
      it 'redirects to login with flash' do
        get :show, id: user
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      before { sign_in create(:user) }

      context 'when html request with without graetzl' do
        it '301 redirects to user in right graetzl' do
          get :show, id: user
          expect(response).to have_http_status 301
          expect(response).to redirect_to [graetzl, user]
        end
      end
      context 'when html request with wrong graetzl' do
        let!(:other_graetzl) { create :graetzl }

        it '301 redirects to user in right graetzl' do
          get :show, graetzl_id: other_graetzl, id: user
          expect(response).to have_http_status 301
          expect(response).to redirect_to [graetzl, user]
        end
      end
      context 'when html request with right graetzl' do
        let!(:wall_comments) { create_list :comment, 10, commentable: user }

        before { get :show, graetzl_id: graetzl, id: user }

        it 'assigns @user' do
          expect(assigns :user).to eq user
        end

        it 'assigns @graetzl' do
          expect(assigns :graetzl).to eq graetzl
        end

        it 'assigns @wall_comments' do
          expect(assigns :wall_comments).to match_array wall_comments
        end

        it 'assigns @initiated and @attended' do
          expect(assigns :initiated).to be
          expect(assigns :attended).to be
        end

        it 'renders show.html' do
          expect(response['Content-Type']).to eq 'text/html; charset=utf-8'
          expect(response).to render_template(:show)
        end
      end
      context 'when js request for comments' do
        let!(:old_wall_comments) { create_list :comment, 10, commentable: user }
        let!(:new_wall_comments) { create_list :comment, 10, commentable: user }

        before { xhr :get, :show, id: user, page: 2 }

        it 'assigns @user' do
          expect(assigns :user).to eq user
        end

        it 'assigns next 10 @wall_comments' do
          expect(assigns :wall_comments).to match_array old_wall_comments
        end

        it 'does not assigns @initated and @attended' do
          expect(assigns :initiated).not_to be
          expect(assigns :attended).not_to be
        end

        it 'renders show.js' do
          expect(response['Content-Type']).to eq 'text/javascript; charset=utf-8'
          expect(response).to render_template(:show)
        end
      end
      context 'when js request for initiated meetings' do
        let(:old_meetings) { create_list :meeting, 3 }
        let(:new_meetings) { create_list :meeting, 3 }

        before do
          old_meetings.each{|m| create(:going_to, :initiator, user: user, meeting: m)}
          new_meetings.each{|m| create(:going_to, :initiator, user: user, meeting: m)}
          xhr :get, :show, id: user, initiated: 2
        end

        it 'assigns @user' do
          expect(assigns :user).to eq user
        end

        it 'assigns next 3 @initiated meetings' do
          expect(assigns :initiated).to match_array new_meetings
        end

        it 'does not assigns @wall_comments' do
          expect(assigns :wall_comments).not_to be
        end

        it 'renders show.js' do
          expect(response['Content-Type']).to eq 'text/javascript; charset=utf-8'
          expect(response).to render_template(:show)
        end
      end
      context 'when js request for attended meetings' do
        let(:old_meetings) { create_list :meeting, 3 }
        let(:new_meetings) { create_list :meeting, 3 }

        before do
          old_meetings.each{|m| create(:going_to, :attendee, user: user, meeting: m)}
          new_meetings.each{|m| create(:going_to, :attendee, user: user, meeting: m)}
          xhr :get, :show, id: user, attended: 2
        end

        it 'assigns @user' do
          expect(assigns :user).to eq user
        end

        it 'assigns next 3 @attended meetings' do
          expect(assigns :attended).to match_array new_meetings
        end

        it 'does not assigns @wall_comments' do
          expect(assigns :wall_comments).not_to be
        end

        it 'renders show.js' do
          expect(response['Content-Type']).to eq 'text/javascript; charset=utf-8'
          expect(response).to render_template(:show)
        end
      end
    end
  end
end
#
#   describe 'GET edit' do
#     context 'when logged out' do
#       it 'redirects to login with flash' do
#         get :edit
#         expect(response).to render_template(session[:new])
#         expect(flash[:alert]).to be_present
#       end
#     end
#     context 'when logged in' do
#       let(:user) { create(:user) }
#       before do
#         sign_in user
#         get :edit
#       end
#
#       it 'assigns @user with current_user' do
#         expect(assigns(:user)).to eq user
#       end
#
#       it 'renders :edit' do
#         expect(response).to render_template(:edit)
#       end
#     end
#   end
#   describe 'PUT update' do
#     context 'when logged out' do
#       it 'redirects to login with flash' do
#         put :update, id: create(:user)
#         expect(response).to render_template(session[:new])
#         expect(flash[:alert]).to be_present
#       end
#     end
#     context 'when logged in' do
#       let!(:user) { create(:user) }
#       let(:params) {
#         {
#           id: user,
#           user: { email: 'new@newer.com' }
#         }
#       }
#       before { sign_in user }
#
#       describe 'change attributes' do
#
#         it 'updates user record' do
#           expect{
#             put :update, params
#             user.reload
#           }.to change(user, :email)
#         end
#
#         it 'does not change password' do
#           expect{
#             put :update, params
#             user.reload
#           }.not_to change(user, :password)
#         end
#
#         describe 'request' do
#           before { put :update, params }
#
#           it 'assigns @user' do
#             expect(assigns(:user)).to eq user
#           end
#
#           it 'redirect_to to current_user with notice' do
#             expect(response).to redirect_to([user.graetzl, user])
#             expect(flash[:notice]).to be_present
#           end
#         end
#       end
#       describe 'change password' do
#         it "is a pending example"
#       end
#     end
#   end
# end
