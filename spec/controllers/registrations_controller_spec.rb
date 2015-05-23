require 'rails_helper'
include GeojsonSupport

RSpec.describe RegistrationsController, type: :controller do

  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'GET address' do
    before { get :address }
      
    it 'returns a 200 OK status' do
      expect(response).to be_success
      expect(response).to have_http_status(:ok)
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

      it 'puts empty address in session' do
        expect(session[:address]).not_to be_nil
        expect(session[:address][:coordinates]).to be_nil
      end

      it 'puts no graetzl in session' do
        expect(session[:graetzl]).to be_nil
      end

      it 'assigns @graetzls empty' do
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

      it 'puts address in session' do
        expect(session[:address]).not_to be_nil
      end

      it 'puts no graetzl in session' do
        expect(session[:graetzl]).to be_nil
      end

      it 'assigns @graetzls empty' do
        expect(assigns(:graetzls)).to be_empty
      end

      it 'renders graetzl' do
        expect(response).to render_template(:graetzl)
      end
    end

    context 'with valid feature param' do
      let(:esterhazygasse) { build(:esterhazygasse) }
      let(:feature_hash) { esterhazygasse_hash }
      before do
        @naschmarkt = create(:naschmarkt)
        2.times { create(:graetzl) }
        post :set_address, address: "#{esterhazygasse.street_name} #{esterhazygasse.street_number}", feature: feature_hash.to_json
      end

      it 'puts address in session' do
        expect(session[:address]).to eql(esterhazygasse.attributes)
      end

      it 'puts graetzl in session' do
        expect(session[:graetzl]).to eql(@naschmarkt.id)
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
end
