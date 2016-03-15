require 'rails_helper'

RSpec.describe GoingTosController, type: :controller do
  let(:graetzl) { create :graetzl }

  describe 'POST create' do
    let(:meeting) { create :meeting, graetzl: graetzl }

    context 'when logged out' do
      it 'returns 401 unauthorized' do
        xhr :post, :create, meeting_id: meeting
        expect(response).to have_http_status 401
      end
    end
    context 'when logged in' do
      let(:user) { create :user }

      before { sign_in user }

      it 'assigns @meeting' do
        xhr :post, :create, meeting_id: meeting
        expect(assigns :meeting).to eq meeting
      end

      it 'creates new going_to record' do
        expect {
          xhr :post, :create, meeting_id: meeting
        }.to change{GoingTo.count}.by 1
      end

      it 'logs activity' do
        expect{
          xhr :post, :create, meeting_id: meeting
        }.to change{Activity.count}.by 1
      end

      it 'renders create.js' do
        xhr :post, :create, meeting_id: meeting
        expect(response['Content-Type']).to eq 'text/javascript; charset=utf-8'
        expect(response).to render_template :create
      end
    end
  end

  describe 'DELETE destroy' do
    let(:user) { create :user }
    let(:meeting) { create :meeting }
    let!(:going_to) { create :going_to, :attendee, user: user, meeting: meeting }

    context 'when logged out' do
      it 'returns 401 unauthorized' do
        xhr :delete, :destroy, id: going_to
        expect(response).to have_http_status 401
      end
    end
    context 'when logged in' do
      before { sign_in user }

      it 'deletes going to record' do
        expect{
          xhr :delete, :destroy, id: going_to
        }.to change{GoingTo.count}.by -1
      end

      it 'assigns @meeting' do
        xhr :delete, :destroy, id: going_to
        expect(assigns :meeting).to eq meeting
      end

      it 'renders destroy.js' do
        xhr :delete, :destroy, id: going_to
        expect(response['Content-Type']).to eq 'text/javascript; charset=utf-8'
        expect(response).to render_template :destroy
      end
    end
  end
end
