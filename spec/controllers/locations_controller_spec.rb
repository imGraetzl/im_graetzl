require 'rails_helper'
include GeojsonSupport

RSpec.describe LocationsController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  before(:each) do
    request.env['HTTP_REFERER'] = 'where_i_came_from'
  end

  # Shared Examples:
  shared_examples :an_unauthenticated_request do
    it 'redirects to login' do
      expect(response).to render_template(session[:new])
    end
  end

  shared_examples :an_unauthorized_request do
    it 'redirects back to previous page' do
      expect(response).to redirect_to 'where_i_came_from'
    end

    it 'shows flash[:error]' do
      expect(flash[:error]).to be_present
    end
  end

  shared_examples :graetzl_context do
    it 'assigns @graetzl' do
      expect(assigns(:graetzl)).to eq graetzl
    end
  end

  shared_examples :a_successfull_location_request do

    it 'assigns @location' do
      expect(assigns(:location)).to eq location
    end
  end


  # Controller methods
  describe 'GET new' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        get :new
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      let!(:district) { create(:district) }
      let!(:user) { create(:user, graetzl: create(:graetzl)) }
      before { sign_in user }

      context 'without graetzl_id param' do
        before { get :new }

        it 'assigns @graetzl with user.graetzl' do
          expect(assigns(:graetzl)).to eq user.graetzl
        end

        it 'assigns @district' do
          expect(assigns(:district)).to eq district
        end

        it 'renders :graetzl_form' do
          expect(response).to render_template(:graetzl_form)
        end
      end

      context 'with graetzl_id param' do
        let!(:graetzl) { create(:graetzl,
          area: 'POLYGON ((20.0 20.0, 20.0 22.0, 22.0 22.0, 20.0 20.0))') }
        let!(:district) { create(:district,
          area: 'POLYGON ((20.0 20.0, 20.0 25.0, 25.0 25.0, 25.0 20.0, 20.0 20.0))') }

        before { get :new, graetzl_id: graetzl }

        it 'assigns @graetzl with graetzl' do
          expect(assigns(:graetzl)).to eq graetzl
        end

        it 'assigns @district' do
          expect(assigns(:district)).to eq district
        end

        it 'renders :graetzl_form' do
          expect(response).to render_template(:graetzl_form)
        end
      end
    end
  end

  describe 'POST new' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        post :new
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      let(:graetzl) { create(:graetzl) }
      let(:user) { create(:user) }

      before do
        sign_in user
        post :new, graetzl_id: graetzl.id
      end

      it 'assigns @graetzl' do
        expect(assigns(:graetzl)).to eq graetzl
      end

      it 'assigns @location' do
        expect(assigns(:location)).to be_a_new(Location)
      end

      it 'renders :new' do
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST create' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        post :create
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      let(:graetzl) { create(:graetzl) }
      let(:user) { create(:user) }
      let(:attrs) { attributes_for(:location) }
      let(:params) {
        {
          location: {
            graetzl_id: graetzl.id,
            name: attrs[:name],
            slogan: attrs[:slogan],
            description: attrs[:description]
          }
        }
      }

      before { sign_in user }

      describe 'with basic attributes' do

        it 'creates new location record' do
          expect{
            post :create, params
          }.to change{Location.count}.by(1)
        end        

        it 'creates new location_ownership record' do
          expect{
            post :create, params
          }.to change{LocationOwnership.count}.by(1)
        end

        it 'redirects to root with notice' do
          post :create, params
          expect(response).to redirect_to root_url
          expect(flash[:notice]).to be_present
        end

        describe 'new location' do
          before { post :create, params }
          subject(:new_location) { Location.last }

          it 'has attributes' do
            expect(new_location).to have_attributes(
              graetzl: graetzl,
              name: attrs[:name],
              slogan: attrs[:slogan],
              description: attrs[:description]
            )
          end

          it 'is pending' do
            expect(new_location.pending?).to eq true
          end

          it 'has current_user associated' do
            expect(new_location.users).to include(user)
          end
        end
      end

      describe 'with contact and address' do
        let(:address) { build(:address) }
        let(:contact) { build(:contact) }

        before do
          params[:location].merge!(contact_attributes: {
            website: contact.website,
            email: contact.email,
            phone: contact.phone })
          params[:location].merge!(address_attributes: {
            street_name: address.street_name,
            street_number: address.street_number,
            zip: address.zip,
            city: address.city,
            coordinates: address.coordinates })
        end

        it 'creates new location record' do
          expect{
            post :create, params
          }.to change{Location.count}.by(1)
        end

        it 'creates new address record' do
          expect{
            post :create, params
          }.to change{Address.count}.by(1)
        end

        it 'creates new contact record' do
          expect{
            post :create, params
          }.to change{Contact.count}.by(1)
        end
      end
    end
  end

  describe 'GET edit' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        get :edit, id: create(:location)
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      let(:user) { create(:user) }
      let(:location) { create(:location) }

      before do
        sign_in user
        get :edit, id: location
      end

      it 'assigns @location' do
        expect(assigns(:location)).to eq location
      end

      it 'renders :edit' do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'PUT update' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        put :update, id: 1
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      let(:location) { create(:location,
                      contact: create(:contact),
                      address: create(:address)) }
      let(:attrs) { attributes_for(:location) } 
      let(:user) { create(:user) }
      let(:params) {
        {
          id: location,
          location: {
            name: attrs[:name],
            slogan: attrs[:slogan],
            description: attrs[:description]
          }
        }
      }

      before { sign_in user }

      describe 'update basic attributes' do
        before do
          put :update, params
          location.reload
        end

        it 'assigns @location' do
          expect(assigns(:location)).to eq location
        end

        it 'updates attributes' do
          expect(location).to have_attributes(
            name: attrs[:name],
            slogan: attrs[:slogan],
            description: attrs[:description])
        end

        it 'redirect_to location in graetzl' do
          expect(response).to redirect_to [location.graetzl, location]
        end
      end

      describe 'update contact and address' do
        let(:address) { build(:address) }
        let(:contact) { build(:contact) }

        before do
          params[:location].merge!(contact_attributes: {
            id: location.contact.id,
            website: contact.website,
            email: contact.email,
            phone: contact.phone })
          params[:location].merge!(address_attributes: {
            id: location.address.id,
            street_name: address.street_name,
            street_number: address.street_number,
            zip: address.zip,
            city: address.city,
            coordinates: address.coordinates })
          put :update, params
          location.reload
        end

        it 'updates contact attributes' do
          expect(location.contact).to have_attributes(
            website: contact.website,
            email: contact.email,
            phone: contact.phone)
        end

        it 'updates address attributes' do
          expect(location.address).to have_attributes(
            street_name: address.street_name,
            street_number: address.street_number,
            zip: address.zip,
            city: address.city)
        end
      end

      describe 'remove address' do
        before do
          params[:location].merge!(address_attributes: {
            id: location.address.id,
            _destroy: 1 })
        end

        it 'removes address from location' do
          expect(location.address).to be_present
          put :update, params
          location.reload
          expect(location.address).not_to be_present
        end

        it 'deletes address record' do
          expect{
            put :update, params
          }.to change{Address.count}.by(-1)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let(:location) { create(:location) }

    context 'when logged out' do
      it 'redirects to login with flash' do
        delete :destroy, id: 1
        expect(response).to render_template(session[:new])
      end
    end

    context 'when logged in' do
      let(:user) { create(:user) }
      before { sign_in user }

      context 'when no location_ownership' do
        it 'redirects back to previous page with flash' do
          delete :destroy, id: location
          expect(response).to redirect_to 'where_i_came_from'
          expect(flash[:error]).to be_present
        end
      end

      context 'when location owner' do
        before { create(:location_ownership, user: user, location: location) }

        it 'assigns @location' do
          delete :destroy, id: location
          expect(assigns(:location)).to eq location
        end

        it 'deletes location record' do
          expect{
            delete :destroy, id: location
          }.to change{Location.count}.by(-1)
        end

        it 'redirects back to previous page' do
          delete :destroy, id: location
          expect(response).to redirect_to 'where_i_came_from'
        end
      end
    end
  end


  # describe 'GET index' do
  #   let!(:location_basic) { create(:location_basic, graetzl: graetzl) }
  #   let!(:location_managed) { create(:location_managed, graetzl: graetzl) }
  #   let!(:location_pending) { create(:location_pending, graetzl: graetzl) }
  #   let!(:other_location) { create(:location, graetzl: create(:graetzl)) }

  #   shared_examples :a_successfull_index_request do

  #     it 'renders :index' do
  #       expect(response).to render_template(:index)
  #     end

  #     it 'assigns @locations' do
  #       expect(assigns(:locations)).to be
  #     end

  #     describe '@locations' do

  #       # it 'contains basic and managed' do
  #       #   expect(assigns(:locations)).to include(location_basic, location_managed)
  #       # end

  #       it 'contains only managed' do
  #         expect(assigns(:locations)).to include(location_managed)
  #       end

  #       it 'does not contain pending' do
  #         expect(assigns(:locations)).not_to include(location_pending)
  #       end

  #       it 'does not contain other locations' do
  #         expect(assigns(:locations)).not_to include(other_location)
  #       end
  #     end
  #   end

  #   context 'when logged out' do    
  #     before { get :index, graetzl_id: graetzl }
  #     include_examples :a_successfull_index_request
  #   end

  #   context 'when business user' do
  #     let(:user) { create(:user_business) }
  #     before do
  #       sign_in user
  #       get :index, graetzl_id: graetzl
  #     end
  #     include_examples :a_successfull_index_request
  #   end

  #   context 'when non business user' do
  #     let(:user) { create(:user) }
  #     before do
  #       sign_in user
  #       get :index, graetzl_id: graetzl
  #     end
  #     include_examples :a_successfull_index_request
  #   end
  # end

  # describe 'GET show' do    
  #   let(:location) { create(:location, graetzl: graetzl) }
  #   let(:location_meeting) { create(:meeting, location: location) }
  #   let(:location_meeting_past) { build(:meeting, location: location, starts_at_date: Date.yesterday) }
  #   before { location_meeting_past.save(validate: false) }

  #   shared_examples :a_successfull_show_request do

  #     it 'renders :show' do
  #       expect(response).to render_template(:show)
  #     end

  #     it 'assigns @location' do
  #       expect(assigns(:location)).to eq location
  #     end

  #     it 'assigns @meetings' do
  #       expect(assigns(:meetings)).to be
  #     end

  #     describe '@meetings' do
  #       subject(:meetings) { assigns(:meetings) }

  #       it 'includes upcoming location meetings' do
  #         expect(meetings).to include(location_meeting)
  #       end

  #       it 'excludes past location meetings' do
  #         expect(assigns(:meetings)).not_to include(location_meeting_past)
  #       end
  #     end
  #   end

  #   context 'when logged out' do
  #     before { get :show, graetzl_id: graetzl, id: location }
  #     include_examples :a_successfull_show_request
  #   end

  #   context 'when business user' do
  #     let(:user) { create(:user) }
  #     before do
  #       sign_in user
  #       get :show, graetzl_id: graetzl, id: location
  #     end
  #     include_examples :a_successfull_show_request
  #   end

  #   context 'when non business user' do
  #     let(:user) { create(:user_business) }
  #     before do
  #       sign_in user
  #       get :show, graetzl_id: graetzl, id: location
  #     end
  #     include_examples :a_successfull_show_request
  #   end

  #   context 'when wrong graetzl' do
  #     before do
  #       get :show, graetzl_id: create(:graetzl).slug, id: location
  #     end

  #     it 'redirects to right graetzl' do
  #       expect(response).to redirect_to [graetzl, location]
  #     end
  #   end
  # end







end
