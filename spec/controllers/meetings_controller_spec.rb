require 'rails_helper'
require 'controllers/shared/meetings_controller'
include GeojsonSupport

RSpec.describe MeetingsController, type: :controller do
  describe 'GET index' do
    let(:graetzl) { create :graetzl }

    context 'when js request' do
      before { get :index, params: { graetzl_id: graetzl, page: 2 }, xhr: true }

      it 'assigns @meetings' do
        expect(assigns :meetings).to be
      end

      it 'renders index.js' do
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template :index
      end
    end
  end

  describe 'GET new' do
    let(:graetzl) { create :graetzl }

    context 'when logged out' do
      it 'redirects to login' do
        get :new
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user, graetzl: graetzl }

      before do
        sign_in user
        get :new
      end

      it_behaves_like :meetings_new

      it 'does not assign @parent' do
        expect(assigns :parent).not_to be
      end

      it 'assign @meeting with address' do
        address = assigns(:meeting).address
        expect(address).not_to be_nil
      end
    end
  end
  describe 'POST create' do
    context 'when logged out' do
      it 'redirects to login' do
        post :create
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      before { sign_in user }

      context 'without feature' do
        let(:graetzl) { create :graetzl }
        let(:params) {
          { meeting: attributes_for(:meeting,
            graetzl_id: graetzl.id,
            address_attributes: attributes_for(:address)) }}

        it_behaves_like :meetings_create

        it 'assigns @parent to user graetzl' do
          post :create, params: params
          expect(assigns :parent).to eq user.graetzl
        end

        it 'creates new address' do
          expect{
            post :create, params: params
          }.to change{Address.count}.by 1
        end
      end
      context 'with feature' do
        let(:original_graetzl) { create :graetzl }
        let!(:graetzl) { create(:graetzl,
          area: 'POLYGON ((15.0 15.0, 15.0 20.0, 20.0 20.0, 20.0 15.0, 15.0 15.0))') }
        let(:feature) { feature_hash(16.0, 16.0) }
        let(:params) {
          { meeting: attributes_for(:meeting,
            graetzl_id: original_graetzl.id,
            address_attributes: { description: 'hello' }),
            feature: feature.to_json }}

        it_behaves_like :meetings_create

        it 'assigns @parent to user graetzl' do
          post :create, params: params
          expect(assigns :parent).to eq user.graetzl
        end

        it 'creates new address' do
          expect{
            post :create, params: params
          }.to change{Address.count}.by 1
        end

        it 'has address and graetzl from feature' do
          post :create, params: params
          meeting = Meeting.last
          expect(meeting.address.street_name).to eq(feature['properties']['StreetName'])
          expect(meeting.address.description).to eq 'hello'
          expect(meeting.graetzl).to eq graetzl
        end
      end
    end
  end
  describe 'GET edit' do
    let(:meeting) { create :meeting }

    context 'when logged out' do
      it 'redirects to login' do
        get :edit, params: { id: meeting }
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      before { sign_in user }

      context 'when user initiator of meeting' do
        before do
          create :going_to, :initiator, user: user, meeting: meeting
          get :edit, params: { id: meeting }
        end

        it 'assigns @meeting' do
          expect(assigns :meeting).to eq meeting
        end

        it 'renders edit' do
          expect(response).to render_template :edit
        end
      end

      it 'raises record not found when user not initiator' do
        expect{
          get :edit, params: { id: meeting }
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it 'raises record not found when user only attendee' do
        expect{
          create :going_to, :attendee, user: user, meeting: meeting
          meeting.reload
          get :edit, params: { id: meeting }
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end
  end
  describe 'DELETE destroy' do
    let(:graetzl) { create :graetzl }
    let(:meeting) { create :meeting, graetzl: graetzl }

    it 'redirects to login when logged out' do
      delete :destroy, params: { id: meeting }
      expect(response).to render_template(session[:new])
    end
    context 'when current_user' do
      let(:user) { create :user }
      before { sign_in user }

      it 'raises record not found when user not initiator' do
        expect{
          delete :destroy, params: { id: meeting }
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it 'raises record not found when user only attendee' do
        expect{
          create :going_to, :attendee, user: user, meeting: meeting
          meeting.reload
          delete :destroy, params: { id: meeting }
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
      context 'when user initiator' do
        before { create :going_to, :initiator, user: user, meeting: meeting }

        it 'flags meeting as :cancelled' do
          expect{
            delete :destroy, params: { id: meeting }
            meeting.reload
          }.to change{meeting.state}.from('basic').to('cancelled')
        end

        it 'redirect_to graetzl with notice' do
          delete :destroy, params: { id: meeting }
          expect(response).to redirect_to graetzl
          expect(flash[:notice]).not_to be nil
        end

        it 'logs meeting.cancel activity' do
          expect{
            delete :destroy, params: { id: meeting }
          }.to change{Activity.count}.by 1
        end
      end
    end
  end
  describe 'PUT update' do
    let(:graetzl) { create :graetzl }
    let(:meeting) { create :meeting, graetzl: graetzl }

    it 'redirects to login when logged out' do
      delete :destroy, params: { id: meeting }
      expect(response).to render_template(session[:new])
    end
    context 'when current_user' do
      let(:user) { create :user }
      before { sign_in user }

      it 'raises record not found when user not initiator' do
        expect{
          put :update, params: { id: meeting }
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it 'raises record not found when user only attendee' do
        expect{
          create :going_to, :attendee, user: user, meeting: meeting
          meeting.reload
          put :update, params: { id: meeting }
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
      context 'when user initiator' do
        before { create :going_to, :initiator, user: user, meeting: meeting }

        let(:params) {{ id: meeting, meeting: attributes_for(:meeting) }}

        it 'assigns @meeting' do
          put :update, params: params
          expect(assigns :meeting).to eq meeting
        end

        it 'redirect_to meeting in graetzl' do
          put :update, params: params
          expect(response).to redirect_to [graetzl, meeting]
        end

        it 'automatically changes state to basic' do
          meeting.cancelled!
          meeting.reload
          expect{
            put :update, params: params
            meeting.reload
          }.to change{meeting.state}.to 'basic'
        end
        context 'time attributes' do
          let(:params) {
            { id: meeting,
              meeting: attributes_for(:meeting,
              starts_at_date: '2020-01-01',
              starts_at_time: '18:00',
              ends_at_time: '20:00') }}

          it 'updates time' do
            put :update, params: params
            meeting.reload
            expect(meeting.starts_at_date.strftime('%Y-%m-%d')).to eq ('2020-01-01')
            expect(meeting.ends_at_date).to be_falsy
            expect(meeting.starts_at_time.strftime('%H:%M')).to eq ('18:00')
            expect(meeting.ends_at_time.strftime('%H:%M')).to eq ('20:00')
          end

          it 'adds changed time attributes to activity parameters hash' do
            put :update, params: params
            activity = meeting.activities.last
            expect(activity.parameters[:changed_attributes]).to include(:starts_at_date)
            expect(activity.parameters[:changed_attributes]).to include(:starts_at_time)
            expect(activity.parameters[:changed_attributes]).to include(:ends_at_time)
          end
        end
        context 'update address' do
          let!(:new_graetzl) { create(:graetzl,
            area: 'POLYGON ((15.0 15.0, 15.0 20.0, 20.0 20.0, 20.0 15.0, 15.0 15.0))') }
          let(:feature) { feature_hash(16.0, 16.0) }
          let(:params) {
            { id: meeting,
              meeting: attributes_for(:meeting, address_attributes: { description: 'hallo' }),
              address: 'hello',
              feature: feature.to_json }}

          it 'updates address and graetzl' do
            put :update, params: params
            meeting.reload
            expect(meeting.graetzl).to eq new_graetzl
            expect(meeting.address).to have_attributes(
              street_name: feature['properties']['StreetName'],
              description: 'hallo')
          end

          it "adds address to activity parameters" do
            put :update, params: params
            activity = meeting.activities.last
            expect(activity.parameters[:changed_attributes]).to include(:address)
          end

          it 'redirects_to meeting in new graetzl' do
            put :update, params: params
            expect(response).to redirect_to [new_graetzl, meeting]
          end
        end
        context 'remove address' do
          let(:address) { create :address }
          let(:meeting) { create :meeting, graetzl: graetzl, address: address }
          let(:params) {
            { id: meeting,
              meeting: attributes_for(:meeting,
                address_attributes: { description: '' }),
                address: '', feature: '' }}

          it 'removes street_name' do
            expect{
              put :update, params: params
              meeting.reload
            }.to change{meeting.address.street_name}.from(address.street_name).to(nil)
          end

          it 'removes coordinates' do
            expect{
              put :update, params: params
              meeting.reload
            }.to change{meeting.address.coordinates}.from(address.coordinates).to(nil)
          end
        end
      end
    end
  end
end
