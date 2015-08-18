require 'rails_helper'
include GeojsonSupport

RSpec.describe MeetingsController, type: :controller do
  let(:graetzl) { create(:graetzl) }

  shared_examples :a_successful_meeting_request do
    it 'assigns @graetzl' do
      expect(assigns(:graetzl)).to eq(graetzl)
    end

    it 'assigns @meeting' do
      expect(assigns(:meeting)).to eq(meeting)
    end
  end

  shared_examples :an_unauthenticated_request do
    it 'redirects to login' do
      expect(response).to render_template(session[:new])
    end
  end

  shared_examples :an_unauthorized_request do
    it 'redirects to meeting_page' do          
      expect(response).to redirect_to([graetzl, meeting])
    end

    it 'shows flash[:error]' do
      expect(flash[:error]).not_to be nil
    end
  end

  describe 'GET show' do
    let(:meeting) { create(:meeting, graetzl: graetzl) }

    before { get :show, graetzl_id: graetzl, id: meeting }

    it 'renders #show' do
      expect(response).to render_template(:show)
    end

    it_behaves_like :a_successful_meeting_request

    it 'assigns @comments' do
      expect(assigns(:comments)).to eq(meeting.comments)
    end
  end

  describe 'GET index' do
    let!(:graetzl_meeting) { create(:meeting, graetzl: graetzl) }
    let!(:other_meeting) { create(:meeting) }

    before { get :index, graetzl_id: graetzl }

    it 'renders #index' do
      expect(response).to render_template(:index)
    end

    it 'assigns @graetzl' do
      expect(assigns(:graetzl)).to eq(graetzl)
    end

    it 'assigns @meetings' do
      expect(assigns(:meetings)).to eq(graetzl.meetings)
    end

    describe '@meetings' do
      subject(:meetings) { assigns(:meetings) }

      it 'includes graetzl meetings' do
        expect(meetings).to include graetzl_meeting
      end

      it 'excludes other meetings' do
        expect(meetings).not_to include other_meeting
      end
    end
  end

  describe 'GET new' do

    shared_examples :a_successful_new_request do
      it 'renders #new' do        
        expect(response).to render_template(:new)
      end

      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq(graetzl)
      end

      it 'assigns @meeting and address' do
        expect(assigns(:meeting)).to be_a_new(Meeting)
        expect(assigns(:meeting).address).to be_a_new(Address)
      end
    end

    context 'when logged out' do
      before { get :new, graetzl_id: graetzl }
      it_behaves_like :an_unauthenticated_request
    end

    context 'when logged in' do
      let(:user) { create(:user) }
      before do
        sign_in user
        get :new, graetzl_id: graetzl
      end

      it_behaves_like :a_successful_new_request

      context 'with location' do
        let(:location) { create(:location_managed) }
        before { get :new, { graetzl_id: graetzl, location_id: location.id } }

        it_behaves_like :a_successful_new_request

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
    context 'when logged out' do
      before { post :create, graetzl_id: graetzl }
      it_behaves_like :an_unauthenticated_request
    end

    context 'when logged in' do
      let(:user) { create(:user) }
      let(:params) {
        {
          graetzl_id: graetzl,
          meeting: attributes_for(:meeting).merge({ address_attributes: { } }),
          feature: '',
          address: ''
        }
      }
      before { sign_in user }
      subject(:new_meeting) { Meeting.last }

      it 'creates new meeting' do
        expect {
          post :create, params
        }.to change(Meeting, :count).by(1)
      end

      it 'redirects_to meeting in @graetzl' do
        post :create, params
        expect(response).to redirect_to([graetzl, new_meeting])
      end

      describe 'meeting' do
        before do
          params[:meeting].merge!({ address_attributes: { description: 'new_description' } })
          post :create, params
        end

        it 'has current_user as initiator' do
          expect(new_meeting.going_tos.last).to have_attributes(
            user: user, role: 'initiator')
        end

        it 'has @graetzl' do
          expect(new_meeting.graetzl).to eq(graetzl)
        end

        it 'has address' do
          expect(new_meeting.address).to be_present
        end

        it 'has address description' do
          expect(new_meeting.address.description).to eq('new_description')
        end
      end

      # context 'with category_ids' do
      #   before do
      #     5.times { create(:category) }
      #     params[:meeting][:category_ids] = Category.all.map(&:id)
      #     # TODO: refactor to use new category style
      #     post :create, params
      #   end

      #   describe 'meeting' do
      #     subject(:new_meeting) { Meeting.last }

      #     it 'has categories' do
      #       expect(new_meeting.categories.size).to eq(5)
      #     end
      #   end
      # end

      context 'with feature' do
        let!(:other_graetzl) { create(:graetzl,
          area: 'POLYGON ((15.0 15.0, 15.0 20.0, 20.0 20.0, 20.0 15.0, 15.0 15.0))') }
        let(:address_feature) { feature_hash(16.0, 16.0) }

        before do
          params[:meeting].merge!({ address_attributes: { description: 'new_description' } })
          params.merge!(feature: address_feature.to_json, address: 'address input')
          post :create, params
        end

        it 'redirects_to meeting in address.graetzl' do
          expect(response).to redirect_to([other_graetzl, new_meeting])
        end

        describe 'meeting' do
          it 'has address from feature' do
            expect(new_meeting.address.street_name).to eq(address_feature['properties']['StreetName'])
          end

          it 'has address_description' do
            expect(new_meeting.address.description).to eq('new_description')
          end

          it 'has address.graetzl as graetzl' do
            expect(new_meeting.graetzl).to eq(other_graetzl)
          end
        end
      end
    end
  end

  describe 'GET edit' do
    let(:user) { create(:user)}
    let(:meeting) { create(:meeting, graetzl: graetzl) }

    context 'when logged out' do
      before { get :edit, graetzl_id: graetzl, id: meeting }

      it_behaves_like :an_unauthenticated_request
    end

    context 'when logged in' do

      before { sign_in user }

      context 'when not initiator' do
        before { get :edit, graetzl_id: graetzl, id: meeting }

        it_behaves_like :an_unauthorized_request
      end

      context 'when initator' do
        let!(:going_to) { create(:going_to, user: user, meeting: meeting, role: GoingTo.roles[:initiator]) }

        before { get :edit, graetzl_id: graetzl, id: meeting }

        it_behaves_like :a_successful_meeting_request

        it 'renders #edit' do        
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe 'PUT update' do
    let(:user) { create(:user) }
    let(:meeting) { create(:meeting, graetzl: graetzl) }
    let(:params) {
      {
        graetzl_id: graetzl,
        id: meeting,
        meeting: { address_attributes: { } },
        feature: '',
        address: ''
      }
    }

    context 'when logged out' do
      before { put :update, params }
      it_behaves_like :an_unauthenticated_request
    end

    context 'when logged in' do
      before { sign_in user }

      context 'when not going' do
        before { put :update, params }
        it_behaves_like :an_unauthorized_request
      end

      context 'when attendee' do
        before do
          create(:going_to, user: user, meeting: meeting)
          put :update, params
        end
        it_behaves_like :an_unauthorized_request
      end

      context 'when initiator' do
        before do
          create(:going_to, user: user, meeting: meeting, role: GoingTo.roles[:initiator])
          put :update, params
        end

        it_behaves_like :a_successful_meeting_request

        it 'updates name and description' do
          params[:meeting].merge!(name: 'New name', description: 'New description')
          put :update, params
          meeting.reload
          expect(meeting).to have_attributes(
            name: 'New name',
            description: 'New description')
        end

        describe 'update time attributes' do
          before do
            params[:meeting].merge!(starts_at_date: '2020-01-01',
                                    starts_at_time: '18:00',
                                    ends_at_time: '20:00')
            PublicActivity.with_tracking do
              put :update, params
              meeting.reload
            end
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

        describe 'categories' do
          before do
            5.times { create(:category, context: Category.contexts[:recreation]) }
            params[:meeting].merge!(category_ids: Category.all.map(&:id))
          end

          it 'updates categories' do
            put :update, params
            meeting.reload
            expect(meeting.categories.size).to eq(5)
          end
        end

        describe 'address' do
          let!(:new_graetzl) { create(:graetzl,
            area: 'POLYGON ((15.0 15.0, 15.0 20.0, 20.0 20.0, 20.0 15.0, 15.0 15.0))') }
          let(:address_feature) { feature_hash(16.0, 16.0) }

          before do
            params[:meeting].deep_merge!(address_attributes: { description: 'New address_description' })
            params.merge!(feature: address_feature.to_json)
            params.merge!(address: 'new address input')

            PublicActivity.with_tracking do
              put :update, params
              meeting.reload
            end
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
          let(:old_address) { create(:address, description: 'blabla') }

          before do
            meeting.address = old_address
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
          let(:location) { create(:location_managed) }

          context 'when business user' do
            before { user.business! }

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
  end

  describe 'DELETE destroy' do
    let(:meeting) { create(:meeting, graetzl: graetzl) }
    let(:user) { create(:user) }

    context 'when logged out' do
      before { delete :destroy, graetzl_id: graetzl, id: meeting }
      it_behaves_like :an_unauthenticated_request
    end

    context 'when logged in' do
      before { sign_in user }
      context 'when initiator' do
        let!(:going_to) { create(:going_to, user: user, meeting: meeting, role: GoingTo.roles[:initiator]) }
        describe 'general' do
          before { delete :destroy, graetzl_id: graetzl, id: meeting }

          it_behaves_like :a_successful_meeting_request

          it 'redirects to graetzl_path' do
            expect(response).to redirect_to(graetzl)
          end

          it 'has flash[:notice]' do
            expect(flash[:notice]).to be_present
          end
        end

        it 'deletes record' do
          expect {
            delete :destroy, graetzl_id: graetzl, id: meeting
          }.to change(Meeting, :count).by(-1)
        end

        it 'deletes going_tos' do
          expect {
            delete :destroy, graetzl_id: graetzl, id: meeting
          }.to change(GoingTo, :count).by(-1)
        end
      end

      context 'when not initiator' do
        let!(:going_to) { create(:going_to, user: user, meeting: meeting) }
        before { delete :destroy, graetzl_id: graetzl, id: meeting }
        it_behaves_like :an_unauthorized_request
      end
    end
  end
end
