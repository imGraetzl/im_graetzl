require 'rails_helper'

RSpec.describe GoingTosController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  let(:meeting) { create(:meeting, graetzl: graetzl) }
  let(:user) { create(:user) }

  describe 'POST create' do
    context 'when no current_user' do

      it 'redirects to login_page' do
        xhr :post, :create, meeting_id: meeting.id
        expect(response).to render_template(session[:new])
      end
    end

    context 'when current_user' do
      before { sign_in user }

      it 'creates new GoingTo record' do
        expect {
          xhr :post, :create, meeting_id: meeting.id
          }.to change(GoingTo, :count).by(1)
      end

      it 'assigns @meeting' do
        xhr :post, :create, meeting_id: meeting.id
        expect(assigns(:meeting)).to eq(meeting)
      end

      it 'renders create.js' do
        xhr :post, :create, meeting_id: meeting.id
        expect(response).to render_template('going_tos/create')
        expect(response.header['Content-Type']).to include('text/javascript')
      end

      it 'creates GoingTo with role attendee' do
        xhr :post, :create, meeting_id: meeting.id
        expect(GoingTo.last).to have_attributes(
          user: user,
          role: GoingTo::ROLES[:attendee])
      end

      it 'adds meeting to user' do
        xhr :post, :create, meeting_id: meeting.id
        expect(user.meetings).to include(meeting)
      end

      it 'adds user to meeting' do
        xhr :post, :create, meeting_id: meeting.id
        expect(meeting.users).to include(user)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:going_to) { create(:going_to, user: user, meeting: meeting) }

    before { sign_in user }

    it 'assigns @meeting' do
      xhr :delete, :destroy, id: going_to.id
      expect(assigns(:meeting)).to eq(meeting)
    end

    it 'removes GoingTo' do
      expect {
        xhr :delete, :destroy, id: going_to.id
        }.to change(GoingTo, :count).by(-1)
    end

    it 'removes user from meeting' do
      xhr :delete, :destroy, id: going_to.id
      expect(meeting.users).not_to include(user)
    end

    it 'removes meeting from user' do
      xhr :delete, :destroy, id: going_to.id
      expect(user.meetings).not_to include(meeting)
      expect(user.going_to?(meeting)).to be_falsey
    end
  end

end
