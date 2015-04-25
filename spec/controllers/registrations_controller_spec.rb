require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do

  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'GET new' do

    context 'without graetzl id in session' do
      it 'redirects to address_registration_path' do
        session[:graetzl] = nil
        get :new
        expect(response).to redirect_to addresses_registration_path
      end
    end

    context 'with graetzl id but empty address in session' do
      let(:naschmarkt) { create(:naschmarkt) }

      it 'renders new' do
        session[:graetzl] = naschmarkt.id
        session[:address] = Address.new.attributes
        get :new
        expect(response).to render_template(:new)
      end
    end
  end


  describe 'POST create' do
    let(:attrs) { attributes_for(:user) }
    let(:graetzl) { create(:graetzl) }
    let(:address) { build(:address) }

    context 'with address and graetzl' do
      before do
        attrs[:address_attributes] = address.attributes
        attrs[:graetzl_attributes] = { name: graetzl.name }
      end

      it 'creates new user with address and graetzl' do
        expect {
          post :create, user: attrs
        }.to change(User, :count).by(1)
        expect(User.last.graetzl).to eq(graetzl)
        expect(User.last.address.coordinates).to eq(address.coordinates)
      end

      it 'clears sessiond data' do
        post :create, user: attrs
        expect(session[:address]).not_to be_present
        expect(session[:graetzl]).not_to be_present
      end
    end

    context 'with empty address' do
      before do
        attrs[:graetzl_attributes] = { name: graetzl.name }
        attrs[:address_attributes] = Address.new().attributes
      end

      it 'creates new user with empty address' do
        expect {
          post :create, user: attrs
        }.to change(User, :count).by(1)
        expect(User.last.graetzl).to eq(graetzl)
        expect(User.last.address).not_to be_nil
        expect(User.last.address.coordinates).to be_nil
        expect(User.last.address.street_name).to be_nil
      end
    end
  end
end