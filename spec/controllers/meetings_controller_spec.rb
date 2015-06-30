require 'rails_helper'
include GeojsonSupport

RSpec.describe MeetingsController, type: :controller do
  let(:graetzl) { create(:graetzl) }

  describe 'GET show' do
    let(:meeting) { create(:meeting, graetzl: graetzl) }
    before { get :show, graetzl_id: graetzl, id: meeting }

    it 'returns a 200 OK status' do
      expect(response).to be_success
    end

    it 'renders #show' do
      expect(response).to render_template(:show)
    end

    it 'assigns @graetzl' do
      expect(assigns(:graetzl)).to eq(graetzl)
    end

    it 'assigns @meeting' do
      expect(assigns(:meeting)).to eq(meeting)
    end

    it 'assigns @comments' do
      expect(assigns(:comments)).to eq(meeting.comments)
    end
  end

  describe 'GET index' do
    let!(:graetzl_meeting) { create(:meeting, graetzl: graetzl) }
    let!(:other_meeting) { create(:meeting) }

    before { get :index, graetzl_id: graetzl }

    it 'returns a 200 OK status' do
      expect(response).to be_success
    end

    it 'renders #index' do
      expect(response).to render_template(:index)
    end

    it 'assigns @graetzl' do
      expect(assigns(:graetzl)).to eq(graetzl)
    end

    it 'assigns @meetings' do
      expect(assigns(:meetings)).to eq(graetzl.meetings)
    end

    it 'includes graetzl meetings' do
      expect(assigns(:meetings)).to include graetzl_meeting
    end

    it 'excludes other meetings' do
      expect(assigns(:meetings)).not_to include other_meeting
    end
  end

  describe 'GET new' do
    let(:user) { create(:user)}

    context 'when logged out' do
      it 'redirects to login' do
        get :new, graetzl_id: graetzl
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      before do
        sign_in user
        get :new, graetzl_id: graetzl
      end

      it 'returns a 200 OK status' do
        expect(response).to be_success
      end

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
  end

  describe 'POST create' do
    let(:user) { create(:user)}

    context 'when logged out' do
      it 'redirects to login' do
        post :create, graetzl_id: graetzl
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      subject(:new_meeting) { Meeting.last }
      let(:params) { {
        graetzl_id: graetzl,
        meeting: attributes_for(:meeting).merge({ address_attributes: { description: '' } }),
        feature: '',
        address: ''}
      }

      before { sign_in user }

      it 'creates new meeting' do
        expect {
          post :create, params
        }.to change(Meeting, :count).by(1)
      end

      it 'redirects_to meeting in @graetzl' do
        post :create, params
        expect(response).to redirect_to([graetzl, new_meeting])
      end

      it 'sets current_user as initiator' do
        post :create, params
        expect(new_meeting.going_tos.last).to have_attributes(
          user: user,
          role: GoingTo::ROLES[:initiator])
      end

      it 'associates @graetzl' do
        post :create, params
        expect(new_meeting.graetzl).to eq(graetzl)
      end

      it 'adds address to meeting' do
        post :create, params
        expect(new_meeting.address).to be_present
      end

      it 'adds address description' do
        params[:meeting][:address_attributes][:description] = 'new_address_description'
        post :create, params
        expect(new_meeting.address.description).to eq('new_address_description')
      end

      context 'with category_ids' do
        before do
          5.times { create(:category) }
          params[:meeting][:category_ids] = Category.all.map(&:id)
        end

        it 'adds categories to meeting' do
          post :create, params
          expect(new_meeting.categories.size).to eq(5)
        end
      end

      context 'with feature' do
        let!(:other_graetzl) { create(:graetzl,
          area: 'POLYGON ((15.0 15.0, 15.0 20.0, 20.0 20.0, 20.0 15.0, 15.0 15.0))') }
        let(:address_feature) { feature_hash(16.0, 16.0) }

        before do
          params[:meeting][:address_attributes][:description] = 'new_address_description'
          params[:feature] = address_feature.to_json
          params[:address] = 'new address input'
          post :create, params
        end

        it 'adds address from feature to meeting' do
          expect(new_meeting.address.street_name).to eq(address_feature['properties']['StreetName'])
        end

        it 'adds address_description to meeting' do
          expect(new_meeting.address.description).to eq('new_address_description')
        end

        it 'associates address.graetzl with @meeting' do
          expect(new_meeting.graetzl).to eq(other_graetzl)
        end

        it 'redirects_to meeting in address.graetzl' do
          expect(response).to redirect_to([other_graetzl, new_meeting])
        end
      end

      context 'with only address_description' do
        before do
          params[:meeting][:address_attributes][:description] = 'new_address_description'
          post :create, params
        end

        it 'adds address description to meeting' do
          expect(new_meeting.address.description).to eq('new_address_description')
        end
      end
    end
  end

  describe 'GET edit' do
    let(:user) { create(:user)}
    let(:meeting) { create(:meeting, graetzl: graetzl) }

    context 'when logged out' do
      it 'redirects to login' do
        get :edit, graetzl_id: graetzl, id: meeting
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      before { sign_in user }

      context 'when not initiator' do
        it 'redirects to meeting_page' do
          get :edit, graetzl_id: graetzl, id: meeting
          expect(response).to redirect_to([graetzl, meeting])
        end
      end

      context 'when initator' do
        let!(:going_to) { create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:initiator]) }

        before { get :edit, graetzl_id: graetzl, id: meeting }

        it 'assigns @meeting' do
          expect(assigns(:meeting)).to eq(meeting)
        end

        it 'assigns @graetzl' do
          expect(assigns(:graetzl)).to eq(graetzl)
        end

        it 'renders #edit' do        
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe 'PUT update' do
    let(:user) { create(:user) }
    let(:meeting) { create(:meeting, graetzl: graetzl) }

    let(:params) { {
      graetzl_id: graetzl,
      id: meeting,
      meeting: attributes_for(:meeting).merge({ address_attributes: { description: 'address description' } }),
      feature: '',
      address: '' }
    }

    context 'when logged out' do
      it 'redirects to login' do
        put :update, params
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      before { sign_in user }

      context 'when not inititor' do
        let!(:going_to) { create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:attendee]) }   

        it 'redirects to meeting' do
          put :update, params
          expect(response).to redirect_to([graetzl, meeting])
        end
      end

      context 'when initiator' do
        let!(:going_to) { create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:initiator]) }

        it 'assigns @meeting' do
          put :update, params
          expect(assigns(:meeting)).to eq(meeting)
        end

        it 'assigns @graetzl' do
          put :update, params
          expect(assigns(:graetzl)).to eq(graetzl)
        end

        before do
          params[:meeting][:name] = 'New name'
          params[:meeting][:description] = 'New description'
          params[:meeting]['starts_at_date'] = '2020-01-01'
          params[:meeting]['starts_at_time'] = '18:00'
          params[:meeting]['ends_at_time'] = '20:00'        
        end

        it 'updates attributes' do
          put :update, params
          expect(meeting.reload).to have_attributes(
            name: 'New name',
            description: 'New description')
        end

        it 'updates time' do
          put :update, params
          meeting.reload
          expect(meeting.starts_at_date.strftime('%Y-%m-%d')).to eq ('2020-01-01')
          expect(meeting.ends_at_date).to be_falsy
          expect(meeting.starts_at_time.strftime('%H:%M')).to eq ('18:00')
          expect(meeting.ends_at_time.strftime('%H:%M')).to eq ('20:00')
        end

        describe 'categories' do
          before do
            5.times { create(:category) }
            params[:meeting][:category_ids] = Category.all.map(&:id)
          end

          it 'updates categories' do
            put :update, params
            meeting.reload
            expect(meeting.categories.size).to eq(5)
          end
        end

        describe 'address_attributes' do
          let!(:new_graetzl) { create(:graetzl,
            area: 'POLYGON ((15.0 15.0, 15.0 20.0, 20.0 20.0, 20.0 15.0, 15.0 15.0))') }
          let(:address_feature) { feature_hash(16.0, 16.0) }

          before do
            params[:meeting][:address_attributes][:description] = 'New address_description'
            params[:feature] = address_feature.to_json              
            params[:address] = 'new address input'

            put :update, params
            meeting.reload
          end

          it 'updates address attributes' do
            expect(meeting.address).to have_attributes(
              street_name: address_feature['properties']['StreetName'],
              description: 'New address_description')
          end

          it 'updates graetzl' do
            expect(meeting.graetzl).to eq(new_graetzl)
          end

          it 'redirects_to meeting in new graetzl' do
            expect(response).to redirect_to([new_graetzl, meeting])
          end
        end

        describe 'remove address' do
          let(:address) { create(:address, description: 'blabla') }

          before { meeting.address = address }

          it 'has address' do
            expect(meeting.address).to eq address
          end

          let(:params) { {
            graetzl_id: graetzl,
            id: meeting,
            meeting: meeting.attributes.merge({ address_attributes: { description: address.description } }),
            feature: '',
            address: '' }
          }

          it 'removes address' do
            put :update, params
            expect(meeting.reload.address).to have_attributes(
              street_name: nil,
              coordinates: nil)
          end

          it 'keeps address_description' do
            put :update, params
            meeting.reload
            expect(meeting.address.description).to eq address.description
          end
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let(:meeting) { create(:meeting, graetzl: graetzl) }
    let(:user) { create(:user) }
    let!(:going_to) { create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:initiator]) }

    context 'when logged in' do
      before { sign_in user }

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

      it 'redirects to graetzl_path' do
        delete :destroy, graetzl_id: graetzl, id: meeting
        expect(response).to redirect_to(graetzl)
      end
    end
  end
end
