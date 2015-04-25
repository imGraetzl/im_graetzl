require 'rails_helper'
include GeojsonSupport

RSpec.describe AddressesController, type: :controller do

  describe 'GET registration' do
    it 'renders first registration step' do
      get :registration
      expect(response).to render_template(:registration)
    end
  end


  describe 'POST search' do

    context 'with blank address param' do
      before do
        3.times { create(:graetzl) }
        post :search, address: ''
      end

      it 'puts empty address but no graetzl in session' do
        expect(session[:address]).not_to be_nil
        expect(session[:address][:coordinates]).to be_nil
        expect(session[:graetzl]).to be_nil
      end

      it 'assigns all graetzls' do
        expect(assigns(:graetzls).size).to eq(Graetzl.all.size)
      end

      it 'renders search' do
        expect(response).to render_template(:search)
      end
    end

    context 'without feature param' do
      before do
        3.times { create(:graetzl) }
        post :search, address: 'someweirdstreet 10'
      end

      it 'puts address but no graetzl in session' do
        expect(session[:address]).not_to be_nil
        expect(session[:graetzl]).to be_nil
      end

      it 'assigns all graetzls' do
        expect(assigns(:graetzls).size).to eq(3)
      end

      it 'renders search' do
        expect(response).to render_template(:search)
      end
    end

    context 'with valid feature param' do
      let(:esterhazygasse) { build(:esterhazygasse) }
      let(:feature_hash) { esterhazygasse_hash }
      before do
        @naschmarkt = create(:naschmarkt)
        2.times { create(:graetzl) }
        post :search, address: "#{esterhazygasse.street_name} #{esterhazygasse.street_number}", feature: feature_hash.to_json
      end

      it 'puts correct address and graetzl in session' do
        expect(session[:address]).to eql(esterhazygasse.attributes)
        expect(session[:graetzl]).to eql(@naschmarkt.id)
      end

      it 'redirects to new user registration' do
        expect(response).to redirect_to new_user_registration_path
      end
    end
  end


  describe 'POST match' do

    context 'when graetzl chosen' do
      let(:naschmarkt) { create(:naschmarkt) }
      before { post :match, graetzl: naschmarkt.id }

      it 'puts graetzl id in session' do
        expect(session[:graetzl]).to eql(naschmarkt.id)
      end

      it 'redirects to new user registration' do
        expect(response).to redirect_to new_user_registration_path
      end
    end
  end
end
