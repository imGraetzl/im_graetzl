require 'rails_helper'

RSpec.describe GoingTosController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  let(:meeting) { create(:meeting, graetzl: graetzl) }
  let(:user) { create(:user) }

  shared_examples :a_successful_request do
    it 'assigns @meeting' do
      expect(assigns(:meeting)).to eq(meeting)
    end
  end

  shared_examples :an_unauthenticated_request do
    it 'redirects to login' do
      expect(response).to render_template(session[:new])
    end
  end

  describe 'POST create' do
    context 'when not logged in' do
      before { xhr :post, :create, meeting_id: meeting.id }
      it_behaves_like :an_unauthenticated_request
    end

    context 'when logged in' do
      before { sign_in user }

      it 'creates new GoingTo record' do
        expect {
          xhr :post, :create, meeting_id: meeting.id
          }.to change(GoingTo, :count).by(1)
      end

      describe 'meeting' do
        before { xhr :post, :create, meeting_id: meeting.id }

        it_behaves_like :a_successful_request

        it 'renders create.js' do
          expect(response).to render_template('going_tos/create')
          expect(response.header['Content-Type']).to include('text/javascript')
        end

        it 'creates GoingTo with role attendee' do
          expect(GoingTo.last).to have_attributes(
            user: user,
            role: 'attendee')
        end

        it 'adds meeting to user' do
          expect(user.meetings).to include(meeting)
        end

        it 'adds user to meeting' do
          expect(meeting.users).to include(user)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:going_to) { create(:going_to, user: user, meeting: meeting) }

    context 'when not logged in' do
      before { xhr :delete, :destroy, id: going_to.id }
      it_behaves_like :an_unauthenticated_request
    end

    context 'when logged in' do
      before { sign_in user }

      it 'removes GoingTo' do
        expect {
          xhr :delete, :destroy, id: going_to.id
          }.to change(GoingTo, :count).by(-1)
      end

      describe 'meeting' do
        before { xhr :delete, :destroy, id: going_to.id }

        it_behaves_like :a_successful_request

        it 'renders destroy.js' do
          expect(response).to render_template('going_tos/destroy')
          expect(response.header['Content-Type']).to include('text/javascript')
        end

        it 'removes user from meeting' do
          expect(meeting.users).not_to include(user)
        end

        it 'removes meeting from user' do
          expect(user.meetings).not_to include(meeting)
          expect(user.going_to?(meeting)).to be_falsey
        end
      end
    end
  end
end