require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do

  before { @request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'GET new' do

    context 'with no graetzl id in session' do
      it 'redirects to address registration' do
        get :new
        expect(response).to redirect_to addresses_registration_path
      end
    end

    context 'with graetzl id but no address in session' do
      let(:naschmarkt) { create(:naschmarkt) }

      it 'renders new' do
        session[:graetzl] = naschmarkt.id
        get :new
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'POST create' do
    let(:attrs) { attributes_for(:user) }
    let(:graetzl) { create(:graetzl) }

    context 'with address and graetzl' do
      before do
        attrs[:address_attributes] = attributes_for(:address)
        attrs[:graetzl_attributes] = { name: graetzl.name }
        session[:address] = attrs[:address_attributes]
        session[:graetzl] = graetzl.id
      end

      it 'creates new user' do
        expect {
          post :create, user: attrs
        }.to change(User, :count).by(1)
      end

      it 'does not create graetzl' do
        expect {
          post :create, user: attrs
        }.not_to change(Graetzl, :count)
        expect(User.last.graetzl).to eq(graetzl)
      end

      it 'clears sessiond data' do
        post :create, user: attrs
        expect(session[:address]).not_to be_present
        expect(session[:graetzl]).not_to be_present
      end
    end

    context 'with only graetzl' do
      before do
        attrs[:graetzl_attributes] = { name: graetzl.name }
      end

      it 'creates new user with empty address' do
        expect {
          post :create, user: attrs
        }.to change(User, :count).by(1)
        expect(User.last.address).to be_nil
      end
    end

    context 'without address and graetzl' do
      it 'does not create user' do
        expect {
          post :create, user: attrs
        }.not_to change(User, :count)
      end
    end
  end

end