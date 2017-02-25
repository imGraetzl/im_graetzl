require 'rails_helper'

RSpec.describe GoingTosController, type: :controller do
  let(:graetzl) { create :graetzl }

  describe 'POST create' do
    let(:meeting) { create :meeting, graetzl: graetzl }

    context 'when logged out' do
      it 'returns 401 unauthorized' do
        post :create, params: { meeting_id: meeting }, xhr: true
        expect(response).to have_http_status 401
      end
    end
    context 'when logged in' do
      let(:user) { create :user }

      before { sign_in user }

      it 'assigns @meeting' do
        post :create, params: { meeting_id: meeting }, xhr: true
        expect(assigns :meeting).to eq meeting
      end

      it 'creates new going_to record' do
        expect {
          post :create, params: { meeting_id: meeting }, xhr: true
        }.to change{GoingTo.count}.by 1
      end

      it 'logs activity' do
        expect{
          post :create, params: { meeting_id: meeting }, xhr: true
        }.to change{Activity.count}.by 1
      end

      it 'renders create.js' do
        post :create, params: { meeting_id: meeting }, xhr: true
        expect(response.content_type).to eq 'text/javascript'
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
        delete :destroy, params: { id: going_to }, xhr: true
        expect(response).to have_http_status 401
      end
    end
    context 'when logged in' do
      before { sign_in user }

      it 'deletes going to record' do
        expect{
          delete :destroy, params: { id: going_to }, xhr: true
        }.to change{GoingTo.count}.by -1
      end

      it 'assigns @meeting' do
        delete :destroy, params: { id: going_to }, xhr: true
        expect(assigns :meeting).to eq meeting
      end

      it 'renders destroy.js' do
        delete :destroy, params: { id: going_to }, xhr: true
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template :destroy
      end
    end
  end
end
