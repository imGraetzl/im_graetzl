require 'rails_helper'
include GeojsonSupport

RSpec.describe MeetingsController, type: :controller do
  let!(:graetzl) { create(:graetzl) }

  # Shared examples
  shared_examples :an_unauthenticated_request do
    it 'redirects to login' do
      expect(response).to render_template(session[:new])
    end
  end

  shared_examples :an_unauthorized_request do
    it 'redirects to meeting_page' do
      expect(response).to redirect_to([meeting.graetzl, meeting])
    end

    it 'shows flash[:error]' do
      expect(flash[:error]).not_to be nil
    end
  end


  describe 'GET show' do
    let!(:meeting) { create(:meeting, graetzl: graetzl) }

    context 'when html request' do
      before { get :show, {graetzl_id: graetzl, id: meeting} }

      it 'assigns @meeting' do
        expect(assigns(:meeting)).to eq meeting
      end

      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq(graetzl)
      end

      it 'renders show.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template(:show)
      end

      it 'assigns @comments' do
        expect(assigns(:comments)).to eq(meeting.comments)
      end

      context 'when wrong graetzl' do
        before do
          get :show, graetzl_id: create(:graetzl).slug, id: meeting
        end

        it 'redirects to right graetzl' do
          expect(response).to redirect_to [graetzl, meeting]
        end
      end
    end

    context 'when js request' do
      before { xhr :get, :show, {graetzl_id: graetzl, id: meeting} }

      it 'renders show.js' do
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template(:show)
      end

      it 'assigns @comments' do
        expect(assigns(:comments)).to eq(meeting.comments)
      end
    end
  end

  describe 'GET index' do
    context 'when html request' do
      before { get :index, graetzl_id: graetzl }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'assigns @map_data' do
        expect(assigns :map_data).to be
      end

      it 'assigns @meetings' do
        expect(assigns :meetings).to be
      end

      it 'renders index.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template(:index)
      end
    end
    context 'when js request' do
      before { xhr :get, :index, graetzl_id: graetzl, page: 2 }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'does not assign @map_data' do
        expect(assigns :map_data).not_to be
      end

      it 'assigns @meetings' do
        expect(assigns :meetings).to be
      end

      it 'renders index.js' do
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET new' do
    context 'when loggged out' do
      it 'redirects to login' do
        get :new
        expect(response).to render_template(session[:new])
      end
      context 'when logged in' do
        let(:user) { create :user }
        before { sign_in user }

        context 'when parent is graetzl' do

        end
      end
    end
    # Shared Examples
    shared_examples :a_successful_new_request do

      it 'assigns @meeting with address and graetzl' do
        expect(assigns(:meeting)).to be_a_new(Meeting)
        expect(assigns(:meeting).address).to be_a_new(Address)
        expect(assigns(:meeting).graetzl).to be_present
      end

      it 'assigns basic @meeting' do
        expect(assigns(:meeting).basic?).to be_truthy
      end

      it 'assigns @parent' do
        expect(assigns(:parent)).not_to be_nil
      end

      it 'renders #new' do
        expect(response).to render_template(:new)
      end
    end

    # Scenarios
    context 'when logged out' do
      include_examples :an_unauthenticated_request do
        before { get :new }
      end
      context 'within graetzl' do
        before { get :new, graetzl_id: graetzl }
        include_examples :an_unauthenticated_request
      end
      context 'within location' do
        before { get :new, location_id: 1 }
        include_examples :an_unauthenticated_request
      end
    end

    context 'when logged in' do
      let!(:user_graetzl) { create(:graetzl) }
      let(:user) { create(:user, graetzl: user_graetzl) }
      before { sign_in user }

      context 'outside graetzl' do
        before { get :new }

        include_examples :a_successful_new_request

        it 'assigns graetzl from user' do
          expect(assigns(:meeting).graetzl).to eq user_graetzl
        end
      end

      context 'within graetzl' do
        before { get :new, graetzl_id: graetzl }

        include_examples :a_successful_new_request

        it 'assigns graetzl from params' do
          expect(assigns(:meeting).graetzl).to eq graetzl
        end
      end

      context 'within location' do
        let(:location) { create(:location, state: Location.states[:approved], address: build(:address)) }
        before { get :new, location_id: location.id }

        include_examples :a_successful_new_request

        it 'assigns graetzl from location' do
          expect(assigns(:meeting).graetzl).to eq location.graetzl
        end

        it 'links location' do
          expect(assigns(:meeting).location).to eq location
        end

        it 'adopts location address and description' do
          expect(assigns(:meeting).address).to have_attributes(
            street_name: location.address.street_name,
            street_number: location.address.street_number,
            zip: location.address.zip,
            city: location.address.city,
            coordinates: location.address.coordinates,
            description: location.name)
        end
      end
    end
  end

  describe 'POST create' do
    # Shared Examples
    shared_examples :a_successful_create_request do
      it 'creates a new meeting record' do
        expect {
          post :create, params
        }.to change(Meeting, :count).by(1)
      end

      it 'creates new address record' do
        expect {
          post :create, params
        }.to change(Address, :count).by(1)
      end

      it 'creates new going_to record' do
        expect {
          post :create, params
        }.to change(GoingTo, :count).by(1)
      end

      it 'assigns @parent' do
        post :create, params
        expect(assigns(:parent)).not_to be_nil
      end

      it 'redirects_to meeting in graetzl' do
        post :create, params
        meeting = Meeting.last
        expect(response).to redirect_to([meeting.graetzl, meeting])
      end
    end

    # Scenarios
    context 'when logged out' do
      before { post :create }
      include_examples :an_unauthenticated_request
    end

    context 'when logged in' do
      let(:user) { create(:user) }
      let(:params) {
        {
          meeting: { name: 'new_meeting', graetzl_id: graetzl.id, address_attributes: {} },
          feature: '',
          address: ''
        }
      }
      before { sign_in user }

      context 'with empty address and feature' do

        include_examples :a_successful_create_request

        describe 'new meeting' do
          before { post :create, params }
          subject(:new_meeting) { Meeting.last }

          it 'has current_user as initiator' do
            expect(new_meeting.going_tos.last).to have_attributes(
              user: user, role: 'initiator')
          end

          it 'has graetzl' do
            expect(new_meeting.graetzl).to eq graetzl
          end

          it 'has address' do
            expect(new_meeting.address).to be_present
          end
        end
      end
      context 'with only address description' do
        before do
          params[:meeting].merge!({ address_attributes: { description: 'new_description' } })
        end

        include_examples :a_successful_create_request

        describe 'new meeting' do
          before { post :create, params }
          subject(:new_meeting) { Meeting.last }

          it 'has current_user as initiator' do
            expect(new_meeting.going_tos.last).to have_attributes(
              user: user, role: 'initiator')
          end

          it 'has graetzl' do
            expect(new_meeting.graetzl).to eq graetzl
          end

          it 'has address with description' do
            expect(new_meeting.address).to be_present
            expect(new_meeting.address.description).to eq 'new_description'
          end
        end
      end
      context 'with address and feature' do
        let!(:other_graetzl) { create(:graetzl,
          area: 'POLYGON ((15.0 15.0, 15.0 20.0, 20.0 20.0, 20.0 15.0, 15.0 15.0))') }
        let(:address_feature) { feature_hash(16.0, 16.0) }

        before do
          params[:meeting].merge!({ address_attributes: { description: 'another_description' } })
          params.merge!(feature: address_feature.to_json, address: 'address input')
        end

        include_examples :a_successful_create_request

        it 'redirects_to meeting in address.graetzl' do
          post :create, params
          meeting = Meeting.last
          expect(response).to redirect_to([other_graetzl, meeting])
        end

        describe 'new meeting' do
          before { post :create, params }
          subject(:new_meeting) { Meeting.last }

          it 'has current_user as initiator' do
            expect(new_meeting.going_tos.last).to have_attributes(
              user: user, role: 'initiator')
          end

          it 'has address from feature' do
            expect(new_meeting.address.street_name).to eq(address_feature['properties']['StreetName'])
          end

          it 'has address_description' do
            expect(new_meeting.address.description).to eq('another_description')
          end

          it 'has address.graetzl as graetzl' do
            expect(new_meeting.graetzl).to eq(other_graetzl)
          end
        end
      end
      context 'with full address and location' do
        let(:address) { build(:address) }
        let!(:location) { create(:location, state: Location.states[:approved]) }
        before do
          params.merge!(address: 'something')
          params[:meeting].merge!({
            location_id: location.id,
            address_attributes: {
              street_name: address.street_name,
              street_number: address.street_number,
              zip: address.zip,
              city: address.city,
              coordinates: address.coordinates,
              description: 'new_description' }
          })
        end

        include_examples :a_successful_create_request

        describe 'new meeting' do
          before { post :create, params }
          subject(:new_meeting) { Meeting.last }

          it 'has current_user as initiator' do
            expect(new_meeting.going_tos.last).to have_attributes(
              user: user, role: 'initiator')
          end

          it 'has location' do
            expect(new_meeting.location).to eq location
          end

          it 'has address from params' do
            expect(new_meeting.address).to have_attributes(
              street_name: address.street_name,
              street_number: address.street_number,
              zip: address.zip,
              city: address.city,
              coordinates: address.coordinates,)
          end
        end
      end
    end
  end

  describe 'GET edit' do
    let(:user) { create(:user)}
    let(:meeting) { create(:meeting, graetzl: graetzl) }

    context 'when logged out' do
      before { get :edit, id: meeting }
      include_examples :an_unauthenticated_request
    end

    context 'when logged in' do
      before { sign_in user }

      context 'when not initiator' do
        before { get :edit, id: meeting }

        it 'redirects to meeting_page' do
          expect(response).to redirect_to([meeting.graetzl, meeting])
        end

        it 'shows flash[:error]' do
          expect(flash[:error]).to be_present
        end
      end

      context 'when initator' do
        let!(:going_to) { create(:going_to,
                          user: user,
                          meeting: meeting,
                          role: GoingTo.roles[:initiator]) }

        context 'when basic meeting' do
          before { get :edit, id: meeting }

          it 'assigns @meeting' do
            expect(assigns(:meeting)).to eq(meeting)
          end

          it 'renders :edit' do
            expect(response).to render_template(:edit)
          end
        end

        context 'when cancelled meeting' do
          before do
            meeting.cancelled!
            get :edit, id: meeting
          end

          it 'assigns @meeting' do
            expect(assigns(:meeting)).to eq(meeting)
          end

          it 'renders :edit' do
            expect(response).to render_template(:edit)
          end
        end
      end
    end
  end

  describe 'PUT update' do
    let(:meeting) { create(:meeting, graetzl: graetzl) }
    let(:params) {
      {
        id: meeting,
        meeting: { address_attributes: { } },
        feature: '',
        address: ''
      }
    }

    context 'when logged out' do
      before { put :update, params }
      include_examples :an_unauthenticated_request
    end

    context 'when logged in' do
      let(:user) { create(:user) }
      before { sign_in user }

      context 'when not going' do
        before { put :update, params }
        include_examples :an_unauthorized_request
      end

      context 'when attendee' do
        before do
          create(:going_to, user: user, meeting: meeting)
          put :update, params
        end
        include_examples :an_unauthorized_request
      end

      context 'when initiator' do
        before do
          create(:going_to,
                  user: user,
                  meeting: meeting,
                  role: GoingTo.roles[:initiator])
        end

        it 'assigns @meeting' do
          put :update, params
          expect(assigns(:meeting)).to eq(meeting)
        end

        describe 'basic attributes' do
          let(:new_meeting) { build(:meeting,
            name: 'name',
            description: 'description') }
          before do
            params[:meeting].merge!(
              name: new_meeting.name,
              description: new_meeting.description)
            put :update, params
            meeting.reload
          end

          it 'updates meeting attributes' do
            expect(meeting).to have_attributes(
              graetzl_id: graetzl.id,
              name: new_meeting.name,
              description: new_meeting.description)
          end

          it 'redirect_to meeting page' do
            expect(response).to redirect_to [meeting.graetzl, meeting]
          end
        end

        describe 'state' do
          context 'when basic meeting' do
            before do
              meeting.basic!
              params[:meeting].merge!(state: Meeting.states[:cancelled])
            end

            it 'does not change state' do
              expect{
                put :update, params
                meeting.reload
              }.not_to change{meeting.state}
            end

            it 'redirect_to meeting page' do
              put :update, params
              expect(response).to redirect_to [meeting.graetzl, meeting]
            end
          end
          context 'when cancelled meeting' do
            before { meeting.cancelled! }

            it 'automatically changes state to basic' do
              expect{
                put :update, params
                meeting.reload
              }.to change{meeting.state}.to 'basic'
            end
          end
        end

        describe 'time attributes' do
          before do
            params[:meeting].merge!(starts_at_date: '2020-01-01',
                                    starts_at_time: '18:00',
                                    ends_at_time: '20:00')
            put :update, params
            meeting.reload
          end

          it 'updates time' do
            expect(meeting.starts_at_date.strftime('%Y-%m-%d')).to eq ('2020-01-01')
            expect(meeting.ends_at_date).to be_falsy
            expect(meeting.starts_at_time.strftime('%H:%M')).to eq ('18:00')
            expect(meeting.ends_at_time.strftime('%H:%M')).to eq ('20:00')
          end

          it "adds changed time attributes to activity parameters hash" do
            activity = meeting.activities.last
            expect(activity.parameters[:changed_attributes]).to include(:starts_at_date)
            expect(activity.parameters[:changed_attributes]).to include(:starts_at_time)
            expect(activity.parameters[:changed_attributes]).to include(:ends_at_time)
          end
        end

        # describe 'categories' do
        #   before do
        #     5.times { create(:category, context: Category.contexts[:recreation]) }
        #     params[:meeting].merge!(category_ids: Category.all.map(&:id))
        #   end

        #   it 'updates categories' do
        #     put :update, params
        #     meeting.reload
        #     expect(meeting.categories.size).to eq(5)
        #   end
        # end

        describe 'address' do
          let!(:new_graetzl) { create(:graetzl,
            area: 'POLYGON ((15.0 15.0, 15.0 20.0, 20.0 20.0, 20.0 15.0, 15.0 15.0))') }
          let(:address_feature) { feature_hash(16.0, 16.0) }

          before do
            params[:meeting].deep_merge!(address_attributes: { description: 'New address_description' })
            params.merge!(feature: address_feature.to_json)
            params.merge!(address: 'new address input')

            put :update, params
            meeting.reload
          end

          it 'updates address attributes' do
            expect(meeting.address).to have_attributes(
              street_name: address_feature['properties']['StreetName'],
              description: 'New address_description')
          end

          it "adds address to activity parameters" do
            activity = meeting.activities.last
            expect(activity.parameters[:changed_attributes]).to include(:address)
          end

          it 'updates graetzl' do
            expect(meeting.graetzl).to eq(new_graetzl)
          end

          it 'redirects_to meeting in new graetzl' do
            expect(response).to redirect_to([new_graetzl, meeting])
          end
        end

        describe 'remove address' do
          let!(:old_address) { create(:address, description: 'blabla', addressable: meeting) }

          before do
            meeting.address = old_address
            meeting.save(validate: false)
            params[:meeting].merge!({ address_attributes: { description: old_address.description } })
          end

          it 'removes street_name' do
            expect{
              put :update, params
              meeting.reload
            }.to change{meeting.address.street_name}.from(old_address.street_name).to(nil)
          end

          it 'removes coordinates' do
            expect{
              put :update, params
              meeting.reload
            }.to change{meeting.address.coordinates}.from(old_address.coordinates).to(nil)
          end

          it 'keeps description' do
            expect{
              put :update, params
            }.to_not change{meeting.address.description}
          end
        end

        describe 'location' do
          let(:location) { create(:location, state: Location.states[:approved]) }

          it 'links location' do
            params[:meeting].merge!(location_id: location.id)
            put :update, params
            meeting.reload
            expect(meeting.location).to eq location
          end

          it 'removes location' do
            meeting.update(location_id: location.id)
            params[:meeting].merge!(location_id: '')
            expect{
              put :update, params
              meeting.reload
            }.to change{meeting.location}.from(location).to nil
          end
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let(:meeting) { create(:meeting, graetzl: graetzl) }

    context 'when logged out' do
      before { delete :destroy, id: meeting }
      include_examples :an_unauthenticated_request
    end

    context 'when logged in' do
      let(:user) { create(:user) }
      before { sign_in user }

      context 'when attendee' do
        before do
          create(:going_to, user: user, meeting: meeting)
          delete :destroy, id: meeting
        end

        include_examples :an_unauthorized_request
      end
      context 'when initiator' do
        before do
          create(:going_to, user: user, meeting: meeting, role: GoingTo.roles[:initiator])
        end

        it 'sets meeting as :cancelled' do
          expect{
            delete :destroy, id: meeting
            meeting.reload
          }.to change{meeting.state}.from('basic').to('cancelled')
        end

        it 'redirect_to graetzl with notice' do
          delete :destroy, id: meeting
          expect(response).to redirect_to(graetzl)
          expect(flash[:notice]).not_to be nil
        end

        it 'logs meeting.cancel activity' do
          delete :destroy, id: meeting
          meeting.reload
          expect(meeting.activities.last.key).to eq 'meeting.cancel'
        end
      end
    end
  end
end
