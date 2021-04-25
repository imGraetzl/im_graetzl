require 'rails_helper'

RSpec.describe ZuckerlsController, type: :controller do
  before do
    allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation)
  end

  describe 'GET new' do
    context 'when logged out' do
      it 'redirects to login' do
        get :new
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }
      before { sign_in user }

      context 'with location_id' do
        let(:location) { create :location, state: Location::states[:approved], user: user }
        before do
          get :new, params: { location_id: location }
        end

        it 'assigns @location' do
          expect(assigns(:location)).to eq location
        end

        it 'renders :new' do
          expect(response).to render_template :new
        end
      end
      context 'when user owns single location' do
        let(:location) { create :location, state: Location::states[:approved], user: user }
        before do
          get :new
        end

        it 'assigns @location' do
          expect(assigns(:location)).to eq location
        end

        it 'renders :new' do
          expect(response).to render_template :new
        end
      end
      context 'when user owns multiple locations' do
        before do
          create_list(:location, 3, user: user, state: Location::states[:approved])
          get :new
        end

        it 'assigns @locations' do
          expect(assigns :locations).to eq user.locations
        end

        it 'renders :new_location' do
          expect(response).to render_template :new_location
        end
      end
    end
  end

  describe 'POST create' do
    let(:user) { create :user }
    let(:location) { create(:location, state: Location::states[:approved], user: user) }

    before do
      sign_in user
    end

    context 'with valid params' do
      let(:params) {
        { location_id: location.id, zuckerl: attributes_for(:zuckerl) }
      }

      it 'creates new zuckerl record' do
        expect{
          post :create, params: params
        }.to change{Zuckerl.count}.by 1
      end

      it 'redirects_to booking_address form' do
        post :create, params: params
        zuckerl = Zuckerl.last
        expect(response).to redirect_to zuckerl_billing_address_path(zuckerl)
      end
    end
    context 'with invalid params' do
      let(:params) {
        { location_id: location.id, zuckerl: attributes_for(:zuckerl, title: '') }
      }

      it 'does not create new zuckerl record' do
        expect{
          post :create, params: params
        }.not_to change{Zuckerl.count}
      end

      it 'renders :new' do
        post :create, params: params
        expect(response).to render_template :new
      end
    end
  end

  describe 'GET edit' do
    let(:location) { create :location }
    let(:zuckerl) { create :zuckerl, location: location }

    context 'when logged out' do
      it 'redirects to login' do
        get :edit, params: { location_id: location, id: zuckerl }
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create :user }

      before { sign_in user }

      context 'when not owner of location' do
        it 'returns 404' do
          expect{
            get :edit, params: { location_id: location, id: zuckerl }
          }.to raise_error ActiveRecord::RecordNotFound
        end
      end
      context 'when owner of location' do
        location.user = user

        context 'when zuckerl :live' do
          let(:zuckerl) { create :zuckerl, :live }

          it 'redirects to zuckerls_user_path with alert' do
            get :edit, params: { location_id: location, id: zuckerl }
            expect(response).to redirect_to zuckerls_user_path
            expect(flash[:alert]).to be_present
          end
        end
        context 'when zuckerl :pending' do
          before { get :edit, params: { location_id: location, id: zuckerl } }

          it 'assigns @location' do
            expect(assigns :location).to eq location
          end

          it 'assigns @zuckerl' do
            expect(assigns :zuckerl).to eq zuckerl
          end

          it 'renders :edit' do
            expect(response).to render_template :edit
          end
        end
      end
    end
  end

  describe 'PUT update' do
    let(:location) { create :location }
    let(:zuckerl) { create :zuckerl, location: location }

    context 'when logged in' do
      let(:user) { create :user }
      before { sign_in user }

      context 'when owner of location' do
        location.user = user

        context 'with valid params' do
          let(:params) { { location_id: location, id: zuckerl, zuckerl: { title: 'new_title' } } }

          it 'updates attributes' do
            expect{
              put :update, params: params
              zuckerl.reload
            }.to change{zuckerl.title}.to 'new_title'
          end

          it 'redirects to zuckerls_user_path with notice' do
            put :update, params: params
            expect(response).to redirect_to zuckerls_user_path
            expect(flash[:notice]).to be_present
          end
        end
        context 'with invalid params' do
          let(:params) { { location_id: location, id: zuckerl, zuckerl: { title: '' } } }

          it 'does not update attributes' do
            expect{
              put :update, params: params
              zuckerl.reload
            }.not_to change{zuckerl.title}
          end

          it 'renders :edit' do
            put :update, params: params
            expect(response).to render_template :edit
          end
        end
        context 'when zuckerl live' do
          let(:zuckerl) { create :zuckerl, :live }

          it 'redirects to zuckerls_user_path with alert' do
            put :update, params: { location_id: location, id: zuckerl }
            expect(response).to redirect_to zuckerls_user_path
            expect(flash[:alert]).to be_present
          end
        end
      end
      context 'when not owner of location' do
        it 'returns 404' do
          expect{
            put :update, params: { location_id: location, id: zuckerl }
          }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end

  describe 'DELETE destroy' do
    let(:location) { create :location }
    let(:zuckerl) { create :zuckerl, location: location }

    context 'when logged in' do
      let(:user) { create :user }
      before { sign_in user }

      context 'when owner of location' do
        location.user = user

        it 'changes zuckerl to :cancelled' do
          expect{
            delete :destroy, params: { location_id: location, id: zuckerl }
            zuckerl.reload
          }.to change{zuckerl.aasm.current_state}.to :cancelled
        end
      end
    end
  end
end
