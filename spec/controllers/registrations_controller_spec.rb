require 'rails_helper'
include GeojsonSupport

RSpec.describe RegistrationsController, type: :controller do

  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'GET address' do
    before { get :address }
      
    it 'returns a 200 OK status' do
      expect(response).to be_success
    end

    it 'renders first registration step' do
      expect(response).to render_template(:address)
    end
  end

  describe 'POST set_address' do
    context 'without :address' do
      before do
        create(:graetzl)
        post :set_address, address: ''
      end

      it 'has empty address in session' do
        expect(session[:address]).not_to be_nil
        expect(session[:address][:coordinates]).to be_nil
      end

      it 'has no graetzl in session' do
        expect(session[:graetzl]).to be_nil
      end

      it 'assigns empty @graetzls' do
        expect(assigns(:graetzls)).to be_empty
      end

      it 'renders graetzl' do
        expect(response).to render_template(:graetzl)
      end
    end

    context 'without :feature' do
      before do
        3.times { create(:graetzl) }
        post :set_address, address: 'someweirdstreet 10'
      end

      it 'has address in session' do
        expect(session[:address]).not_to be_nil
      end

      it 'has no graetzl in session' do
        expect(session[:graetzl]).to be_nil
      end

      it 'assigns empty @graetzls' do
        expect(assigns(:graetzls)).to be_empty
      end

      it 'renders graetzl' do
        expect(response).to render_template(:graetzl)
      end
    end

    context 'with :feature' do
      let(:esterhazygasse) { build(:esterhazygasse) }
      let!(:naschmarkt) { create(:naschmarkt) }
      let(:params) {
        {
          address: "#{esterhazygasse.street_name} #{esterhazygasse.street_number}",
          feature: esterhazygasse_hash.to_json
        }
      }
      before do
        2.times { create(:graetzl) }
        post :set_address, params
      end

      it 'has address in session' do
        expect(session[:address]).to eql(esterhazygasse.attributes)
      end

      it 'has graetzl in session' do
        expect(session[:graetzl]).to eql(naschmarkt.id)
      end

      it 'redirects to new user registration' do
        expect(response).to redirect_to new_user_registration_path
      end
    end
  end

  describe 'POST set_graetzl' do
    context 'with :graetzl' do
      let(:naschmarkt) { create(:naschmarkt) }
      before { post :set_graetzl, graetzl: naschmarkt.id }

      it 'puts graetzl id in session' do
        expect(session[:graetzl]).to eql(naschmarkt.id)
      end

      it 'redirects to new user registration' do
        expect(response).to redirect_to new_user_registration_path
      end
    end
  end

  describe 'GET new' do
    context 'without graetzl' do
      it 'redirects to address_registration' do
        get :new
        expect(response).to redirect_to user_registration_address_path
      end
    end

    context 'with graetzl in session' do
      let!(:naschmarkt) { create(:naschmarkt) }
      let(:params) {
        {
          graetzl: "#{naschmarkt.id}"
        }
      }

      before { get :new, nil, params }

      it 'renders new' do
        expect(response).to render_template(:new)
      end

      it 'assigns @user' do
        expect(assigns(:user)).not_to be_nil
      end

      it 'assigns @address' do
        expect(assigns(:user).address).not_to be_nil
      end

      it 'assigns @graetzl' do
        expect(assigns(:user).graetzl).not_to be_nil
      end
    end
  end

  describe 'POST create' do
    let(:address) { build(:address) }
    let!(:graetzl) { create(:graetzl) }
    let(:params) {
      {
        user: attributes_for(:user).merge(
          { address_attributes: address.attributes,
            graetzl_id: graetzl.id }),
      }
    }
    context 'with all attributes' do
      subject(:new_user) { User.last }
      
      it 'creates new user' do
        expect{
          post :create, params
        }.to change(User, :count).by(1)
      end

      it 'associates graetzl' do
        post :create, params
        expect(new_user.graetzl).to eq graetzl
      end

      it 'associates address' do
        post :create, params
        expect(new_user.address).to have_attributes(
          street_name: address.street_name,
          street_number: address.street_number,
          zip: address.zip,
          city: address.city,
          coordinates: address.coordinates,
          addressable_id: new_user.id,
          addressable_type: 'User')
      end
    end
  end
end
