require 'rails_helper'

RSpec.describe BillingAddressesController, type: :controller do
  before do
    allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation)
  end

  describe 'GET show' do
    context 'when logged out' do
      it 'redirects to login' do
        get :show, zuckerl_id: create(:zuckerl)
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      let(:location) { create :location, state: Location.states[:approved] }
      let(:zuckerl) { create :zuckerl, location: location }

      before do
        create :location_ownership, user: user, location: location
        sign_in user
      end

      context 'when no billing_address' do
        before { get :show, zuckerl_id: zuckerl }

        it 'assigns @zuckerl' do
          expect(assigns :zuckerl).to eq zuckerl
        end

        it 'assigns @location' do
          expect(assigns :location).to eq location
        end

        it 'assigns new @billing_address' do
          expect(assigns :billing_address).to be_a_new BillingAddress
        end

        it 'renders :show' do
          expect(response).to render_template :show
        end
      end
      context 'with billing_address' do
        let!(:billing_address) { create :billing_address, location: location }
        before { get :show, zuckerl_id: zuckerl }

        it 'assigns @zuckerl' do
          expect(assigns :zuckerl).to eq zuckerl
        end

        it 'assigns @location' do
          expect(assigns :location).to eq location
        end

        it 'assigns @billing_address' do
          expect(assigns :billing_address).to eq billing_address
        end

        it 'renders :show' do
          expect(response).to render_template :show
        end
      end
    end
  end

  describe 'POST create' do
    context 'when logged out' do
      it 'redirects to login' do
        post :create, billing_address: attributes_for(:billing_address), zuckerl_id: create(:zuckerl)
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      let(:location) { create :location, state: Location.states[:approved] }
      let(:zuckerl) { create :zuckerl, location: location }

      before { sign_in user }

      context 'with valid params' do
        let(:params) {
          { zuckerl_id: zuckerl,
            billing_address: { full_name: 'Jane Doe',
                              company: 'any',
                              street: 'Somestreet 1',
                              full_city: '1070 Vienna'} }
        }

        it 'creates new billing_address' do
          expect{
            post :create, params
          }.to change{BillingAddress.count}.by 1
        end

        it 'assigns @location, @zuckerl and @billing_address' do
          post :create, params
          expect(assigns :location).to eq location
          expect(assigns :zuckerl).to eq zuckerl
          expect(assigns :billing_address).to be_a(BillingAddress)
        end

        it 'redirects to @billing_address with notice' do
          post :create, params
          expect(response).to redirect_to zuckerl_billing_address_path(zuckerl_id: zuckerl)
          expect(flash[:notice]).to be_present
        end
      end
      context 'with invalid params' do
        let(:params) {
          { zuckerl_id: zuckerl,
            billing_address: { full_name: '' }
          }
        }

        it 'does not create a new billing_address' do
          expect{
            post :create, params
          }.not_to change{BillingAddress.count}
        end

        it 'assigns @location, @zuckerl and @billing_address' do
          post :create, params
          expect(assigns :location).to eq location
          expect(assigns :zuckerl).to eq zuckerl
          expect(assigns :billing_address).to be_a(BillingAddress)
        end

        it 'renders :show' do
          post :create, params
          expect(response).to render_template :show
        end
      end
    end
  end

  describe 'PUT update' do
    context 'when logged out' do
      it 'redirects to login' do
        put :update, billing_address: attributes_for(:billing_address), zuckerl_id: create(:zuckerl)
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      let!(:location) { create :location, state: Location.states[:approved] }
      let(:zuckerl) { create :zuckerl, location: location }
      let!(:billing_address) { create :billing_address, location: location }

      before { sign_in user }

      context 'with valid params' do
        let(:params) {
          { zuckerl_id: zuckerl,
            billing_address: { full_name: 'Jane Doe' } }
        }

        it 'updates new billing_address' do
          expect{
            put :update, params
            billing_address.reload
          }.to change{billing_address.attributes}
        end

        it 'assigns @location, @zuckerl and @billing_address' do
          put :update, params
          expect(assigns :location).to eq location
          expect(assigns :zuckerl).to eq zuckerl
          expect(assigns :billing_address).to eq billing_address
        end

        it 'redirects to @billing_address with notice' do
          put :update, params
          expect(response).to redirect_to zuckerl_billing_address_path(zuckerl_id: zuckerl)
          expect(flash[:notice]).to be_present
        end
      end

    end
  end
end
