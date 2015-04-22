require 'rails_helper'

RSpec.describe AddressesController, type: :controller do

  describe 'GET registration' do
    it 'renders first registration step' do
      get :registration
      expect(response).to render_template(:registration)
    end
  end

  describe 'POST search' do
    context 'without address param' do
      before { post :search }

      it 'shows flash message and discards it on refresh' do
        expect(flash[:error]).to be_present
        get :registration
        expect(flash[:error]).not_to be_present
      end

      it 'renders registration again' do
        expect(response).to render_template(:registration)
      end

      it 'assigns nothing' do
        expect(session[:address]).to be_nil
        expect(session[:graetzls]).to be_nil
      end
    end

    context 'with blank address param' do
      before { post :search, address: '' }

      it 'shows flash message' do
        expect(flash[:error]).to be_present
      end

      it 'renders search again' do
        expect(response).to render_template(:registration)
      end
    end

    context 'with random address param' do
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

    context 'with matching address param' do
      let(:esterhazygasse) { build(:esterhazygasse) }
      before do
        @naschmarkt = create(:naschmarkt)
        2.times { create(:graetzl) }
        post :search, address: "#{esterhazygasse.street_name} #{esterhazygasse.street_number}"
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
    context 'when no graetzl chosen' do
      before { post :match }

      it 'shows flash message' do
        expect(flash[:error]).to be_present
      end

      it 'renders search again' do
        expect(response).to render_template(:search)
      end

      it 'puts no graetzl in session' do
        expect(session[:graetzl]).to be_nil
      end
    end

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
