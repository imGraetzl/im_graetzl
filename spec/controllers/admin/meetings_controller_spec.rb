require 'rails_helper'

RSpec.describe Admin::MeetingsController, type: :controller do
  let(:admin) { create(:user, :admin) }

  before { sign_in admin }

  describe 'GET index' do
    before { get :index }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @meetings' do
      expect(assigns(:meetings)).not_to be_nil
    end

    it 'renders :index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET show' do
    let(:meeting) { create(:meeting) }
    before { get :show, id: meeting }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @meeting' do
      expect(assigns(:meeting)).to eq meeting
    end

    it 'renders :show' do
      expect(response).to render_template(:show)
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @meeting' do
      expect(assigns(:meeting)).to be_a_new(Meeting)
    end

    it 'renders :new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:graetzl) { create(:graetzl) }
    let(:location) { create(:location) }
    let(:meeting) { build(:meeting,
      graetzl: graetzl,
      name: 'name',
      description: 'description',
      location: location) }
    let(:params) {
      {
        meeting: {
          graetzl_id: meeting.graetzl.id,
          name: meeting.name,
          description: meeting.description,
          location_id: location.id
        }
      }
    }

    context 'with basic attributes' do

      it 'creates new meeting record' do
        expect{
          post :create, params
        }.to change{Meeting.count}.by(1)
      end

      it 'assigns attributes to meeting' do
        post :create, params
        m = Meeting.last
        expect(m).to have_attributes(
          graetzl_id: graetzl.id,
          name: meeting.name,
          description: meeting.description,
          location_id: location.id)
      end

      it 'redirects_to new meeting page' do
        post :create, params
        new_meeting = Meeting.last
        expect(response).to redirect_to(admin_meeting_path(new_meeting))
      end
    end

    context 'with address and going_tos' do
      let(:address) { build(:address) }
      let(:going_to_1) { build(:going_to, user: create(:user)) }
      let(:going_to_2) { build(:going_to, user: create(:user)) }
      before do
        params[:meeting].merge!(address_attributes: {
          street_name: address.street_name,
          street_number: address.street_number,
          zip: address.zip,
          city: address.city,
          coordinates: address.coordinates
          })
        params[:meeting].merge!(going_tos_attributes: {
          '0' => {
              user_id: going_to_1.user_id,
              role: going_to_1.role
            },
          '1' => {
              user_id: going_to_2.user_id,
              role: going_to_2.role
            },
          })
      end

      it 'creates new meeting record' do
        expect{
          post :create, params
        }.to change{Meeting.count}.by(1)
      end

      it 'creates new address record' do
        expect{
          post :create, params
        }.to change{Address.count}.by(1)
      end

      it 'creates new going_to records' do
        expect{
          post :create, params
        }.to change{GoingTo.count}.by(2)
      end

      it 'redirects_to new meeting page' do
        post :create, params
        new_meeting = Meeting.unscoped.last
        expect(response).to redirect_to(admin_meeting_path(new_meeting))
      end

      describe 'new meeting' do
        before { post :create, params }
        subject(:new_meeting) { Meeting.unscoped.last }

        it 'is has address' do
          expect(new_meeting.address).not_to be_nil
        end

        it 'assigns address_attributes' do
          expect(Address.last).to have_attributes(
            street_name: address.street_name,
            street_number: address.street_number,
            zip: address.zip,
            city: address.city,
            coordinates: address.coordinates)
        end

        it 'has users' do
          expect(new_meeting.users.count).to eq 2
        end
      end
    end
  end

  describe 'GET edit' do
    let(:meeting) { create(:meeting) }
    before { get :edit, id: meeting }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @meeting' do
      expect(assigns(:meeting)).to eq meeting
    end

    it 'renders :edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT update' do
    let!(:meeting) { create(:meeting) }
    let(:new_meeting) { build(:meeting,
                      graetzl: create(:graetzl),
                      location: create(:location),
                      state: Meeting.states[:cancelled]) }
    let(:params) {
      {
        id: meeting,
        meeting: {
          graetzl_id: new_meeting.graetzl.id,
          name: new_meeting.name,
          state: new_meeting.state,
          description: new_meeting.description,
          location_id: new_meeting.location.id}
      }
    }

    context 'with basic attributes' do
      before do
        put :update, params
        meeting.reload
      end

      it 'redirects to meeting page' do
        expect(response).to redirect_to(admin_meeting_path(meeting))
      end

      it 'updates meeting attributes' do
        expect(meeting).to have_attributes(
          graetzl_id: new_meeting.graetzl.id,
          name: new_meeting.name,
          state: 'cancelled',
          description: new_meeting.description,
          location: new_meeting.location)
      end
    end

    context 'with going_tos' do
      describe 'add user' do
        let!(:user) { create(:user) }
        before do
          params[:meeting].merge!(going_tos_attributes: {
            '0' => { user_id: user.id }
            })
        end

        it 'creates new going_to record' do
          expect{
            put :update, params
          }.to change(GoingTo, :count).by(1)
        end

        it 'adds user to meeting' do
          put :update, params
          expect(meeting.reload.users).to include(user)
        end
      end

      describe 'remove user' do
        let!(:going_to) { create(:going_to, meeting: meeting) }
        before do
          params[:meeting].merge!(going_tos_attributes: {
            '0' => { id: going_to.id, _destroy: 1 }
            })

          it 'destroys going_to record' do
            expect(GoingTo.count).to eq 1
            expect{
              put :update, params
            }.to change(GoingTo, :count).by(-1)
          end

          it 'removes user from meeting' do
            expect(meeting.users). to include(new_user)
            put :update, params
            meeting.reload
            expect(meeting.users).not_to include(new_user)
          end
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:meeting) { create(:meeting) }

    it 'deletes meeting record' do
      expect{
        delete :destroy, id: meeting
      }.to change{Meeting.count}.by(-1)
    end

    it 'redirects_to index page' do
      delete :destroy, id: meeting
      expect(response).to redirect_to(admin_meetings_path)
    end
  end
end
