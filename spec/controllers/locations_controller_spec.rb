require 'rails_helper'
include GeojsonSupport

RSpec.describe LocationsController, type: :controller do
  describe 'GET index' do
    let!(:graetzl) { create :graetzl }
    let!(:old_locations) { create_list :location, 15, :approved, graetzl: graetzl }
    let!(:new_locations) { create_list :location, 15, :approved, graetzl: graetzl }

    context 'when html request' do
      before { get :index, graetzl_id: graetzl }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'assigns @map_data' do
        expect(assigns :map_data).to be_present
      end

      it 'assigns 15 @locations' do
        expect(assigns :locations).to match_array new_locations
      end

      it 'renders index.html' do
        expect(response.content_type).to eq 'text/html'
        expect(response).to render_template :index
      end
    end
    context 'when js request for more locations' do
      before { xhr :get, :index, graetzl_id: graetzl, page: 2 }

      it 'assigns @graetzl' do
        expect(assigns :graetzl).to eq graetzl
      end

      it 'does not assign @map_data' do
        expect(assigns :map_data).not_to be
      end

      it 'assigns older 15 @locations' do
        expect(assigns :locations).to match_array old_locations
      end

      it 'renders index.js' do
        expect(response.content_type).to eq 'text/javascript'
        expect(response).to render_template :index
      end
    end
  end

  describe 'GET show' do
    let(:graetzl) { create :graetzl }
    context 'when location :approved' do
      let(:location) { create :location, :approved, graetzl: graetzl }
      let!(:old_location_posts) { create_list :location_post, 10, author: location, graetzl: graetzl }
      let!(:new_location_posts) { create_list :location_post, 10, author: location, graetzl: graetzl }

      context 'when html request' do
        before { get :show, graetzl_id: graetzl, id: location }

        it 'assigns @graetzl' do
          expect(assigns :graetzl).to eq graetzl
        end

        it 'assigns @location' do
          expect(assigns :location).to eq location
        end

        it 'assigns 10 new @posts' do
          expect(assigns :posts).to match_array new_location_posts
        end

        it 'renders show.html' do
          expect(response.content_type).to eq 'text/html'
          expect(response).to render_template(:show)
        end
      end
      context 'when js request' do
        before { xhr :get, :show, graetzl_id: graetzl, id: location, page: 2 }

        it 'assigns @graetzl' do
          expect(assigns :graetzl).to eq graetzl
        end

        it 'assigns @location' do
          expect(assigns :location).to eq location
        end

        it 'assigns 10 older @posts' do
          expect(assigns :posts).to match_array old_location_posts
        end

        it 'renders show.js' do
          expect(response.content_type).to eq 'text/javascript'
          expect(response).to render_template(:show)
        end
      end
    end
    context 'when location not approved' do
      let(:location) { create :location, :pending, graetzl: graetzl }

      it 'returns 404' do
        expect{
          get :show, graetzl_id: graetzl, id: location
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET new' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        get :new
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      let!(:district) { create :district, area: 'POLYGON ((0.0 0.0, 0.0 1.0, 1.0 1.0, 0.0 0.0))' }
      let(:graetzl) { create :graetzl, area: 'POLYGON ((0.1 0.1, 0.1 0.5, 0.5 0.5, 0.1 0.1))' }
      let(:user) { create :user, graetzl: graetzl }

      before { sign_in user }

      context 'without graetzl_id param' do
        before { get :new }

        it 'assigns @graetzl with user.graetzl' do
          expect(assigns :graetzl).to eq graetzl
        end

        it 'assigns @district' do
          expect(assigns :district).to eq district
        end

        it 'renders :graetzl_form' do
          expect(response).to render_template :graetzl_form
        end
      end
      context 'with graetzl_id param' do
        let(:other_graetzl) { create :graetzl, area: 'POLYGON ((0.1 0.1, 0.1 0.5, 0.5 0.5, 0.1 0.1))' }
        before { get :new, graetzl_id: other_graetzl.id }

        it 'assigns @graetzl with other_graetzl' do
          expect(assigns :graetzl).to eq other_graetzl
        end

        it 'assigns @district' do
          expect(assigns :district).to eq district
        end

        it 'renders :graetzl_form' do
          expect(response).to render_template :graetzl_form
        end
      end
    end
  end

  describe 'POST new' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        post :new
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be_present
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
        expect(assigns :graetzl).to eq graetzl
      end

      it 'assigns @location' do
        expect(assigns :location).to be_a_new Location
      end

      it 'renders :new' do
        expect(response).to render_template :new
      end
    end
  end

  describe 'POST create' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        post :create
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      let(:user) { create(:user) }
      let(:graetzl) { create(:graetzl) }
      let!(:category) { create(:category, context: Category.contexts[:business]) }
      let(:attrs) { attributes_for(:location) }
      let(:params) { { location: {
        graetzl_id: graetzl.id,
        name: attrs[:name],
        location_type: attrs[:location_type],
        slogan: attrs[:slogan],
        description: attrs[:description],
        category_id: category.id }}}

      before { sign_in user }

      context 'with basic attributes' do
        it 'creates location record' do
          expect{
            post :create, params
          }.to change{Location.count}.by 1
        end

        it 'creates location_ownership record' do
          expect{
            post :create, params
          }.to change{LocationOwnership.count}.by 1
        end

        it 'does not create category record' do
          expect{
            post :create, params
          }.not_to change{Category.count}
        end

        it 'assigns @location' do
          post :create, params
          expect(assigns :location).to have_attributes(
            state: 'pending',
            graetzl: graetzl,
            name: attrs[:name],
            category: category,
            slogan: attrs[:slogan],
            description: attrs[:description]
          )
        end

        it 'redirects to root with notice' do
          post :create, params
          expect(response).to redirect_to root_url
          expect(flash[:notice]).to be_present
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
            city: address.city})
        end

        it 'creates new location record' do
          expect{
            post :create, params
          }.to change{Location.count}.by 1
        end

        it 'creates new address record' do
          expect{
            post :create, params
          }.to change{Address.count}.by 1
        end

        it 'creates new contact record' do
          expect{
            post :create, params
          }.to change{Contact.count}.by 1
        end
      end

      describe 'with empty contact and address' do
        before do
          params[:location].merge!(contact_attributes: {
            website: '',
            email: '',
            phone: '' })
          params[:location].merge!(address_attributes: {
            street_name: '',
            street_number: '',
            zip: '',
            city: ''})
        end

        it 'creates new location record' do
          expect{
            post :create, params
          }.to change{Location.count}.by 1
        end

        it 'does not create new address record' do
          expect{
            post :create, params
          }.not_to change{Address.count}
        end

        it 'creates empty contact record' do
          expect{
            post :create, params
          }.to change{Contact.count}.by 1
        end
      end
    end
  end

  describe 'GET edit' do
    context 'when logged out' do
      it 'redirects to login with flash' do
        get :edit, id: 1
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      let(:user) { create(:user) }

      before { sign_in user }

      context 'when approved location' do
        let(:location) { create(:location, :approved) }

        before { get :edit, id: location }

        it 'assigns @location' do
          expect(assigns :location).to eq location
        end

        it 'renders :edit' do
          expect(response).to render_template :edit
        end
      end
      context 'when not approved' do
        let(:location) { create :location, :pending }

        it 'returns 404' do
          expect{
            get :edit, id: location
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe 'PUT update' do
    context 'when logged out' do
      let(:location) { create :location, :approved }

      it 'redirects to login with flash' do
        put :update, id: location
        expect(response).to redirect_to new_user_session_path
        expect(flash[:alert]).to be_present
      end
    end
    context 'when logged in' do
      before { sign_in create :user }

      context 'when not approved' do
        let(:location) { create :location, :pending }

        it 'returns 404' do
          expect{
            put :update, id: location
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
      context 'when approved' do
        let(:location) { create(:location, :approved,
          contact: create(:contact),
          address: create(:address),
          category: create(:category)) }
        let(:attrs) { attributes_for :location, meeting_permission: 'non_meetable' }
        let(:params) {{ id: location, location: {
          name: attrs[:name],
          slogan: attrs[:slogan],
          description: attrs[:description],
          meeting_permission: attrs[:meeting_permission] }}}

        describe 'change basic attributes' do
          before do
            put :update, params
            location.reload
          end

          it 'assigns @location' do
            expect(assigns :location).to eq location
          end

          it 'updates attributes' do
            expect(location).to have_attributes(
              name: attrs[:name],
              slogan: attrs[:slogan],
              description: attrs[:description],
              meeting_permission: attrs[:meeting_permission])
          end

          it 'redirect_to location in graetzl' do
            expect(response).to redirect_to [location.graetzl, location]
          end
        end
        describe 'change contact, category and address' do
          let(:address) { build(:address) }
          let(:contact) { build(:contact) }
          let(:category) { create(:category) }

          before do
            params[:location].merge!(category_id: category.id)
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

          it 'updates contact' do
            expect(location.contact).to have_attributes(
              website: contact.website,
              email: contact.email,
              phone: contact.phone)
          end

          it 'updates address' do
            expect(location.address).to have_attributes(
              street_name: address.street_name,
              street_number: address.street_number,
              zip: address.zip,
              city: address.city)
          end

          it 'updates category' do
            expect(location.category).to eq category
          end
        end
        describe 'remove address' do
          before { params[:location].merge!(address_attributes: { id: location.address.id, _destroy: 1 }) }

          it 'removes address from location' do
            expect{
              put :update, params
              location.reload
            }.to change{location.address}.to nil
          end

          it 'deletes address record' do
            expect{
              put :update, params
            }.to change{Address.count}.by -1
          end
        end
        describe 'change graetzl' do
          let(:new_graetzl) { create(:graetzl) }
          
          before { params[:location].merge!(graetzl_id: new_graetzl.id) }

          it 'updates graetzl' do
            expect{
              put :update, params
              location.reload
            }.to change{location.graetzl}.to new_graetzl
          end
        end
      end
    end
  end
  #
  # describe 'DELETE destroy' do
  #   let(:location) { create(:location) }
  #
  #   context 'when logged out' do
  #     it 'redirects to login with flash' do
  #       delete :destroy, id: 1
  #       expect(response).to render_template(session[:new])
  #     end
  #   end
  #
  #   context 'when logged in' do
  #     let(:user) { create(:user) }
  #     before { sign_in user }
  #
  #     context 'when no location_ownership' do
  #       it 'redirects back to previous page with flash' do
  #         delete :destroy, id: location
  #         expect(response).to redirect_to 'where_i_came_from'
  #         expect(flash[:error]).to be_present
  #       end
  #     end
  #
  #     context 'when location owner' do
  #       before { create(:location_ownership, user: user, location: location) }
  #
  #       it 'assigns @location' do
  #         delete :destroy, id: location
  #         expect(assigns(:location)).to eq location
  #       end
  #
  #       it 'deletes location record' do
  #         expect{
  #           delete :destroy, id: location
  #         }.to change{Location.count}.by(-1)
  #       end
  #
  #       it 'redirects back to previous page' do
  #         delete :destroy, id: location
  #         expect(response).to redirect_to 'where_i_came_from'
  #       end
  #     end
  #   end
  # end
end
