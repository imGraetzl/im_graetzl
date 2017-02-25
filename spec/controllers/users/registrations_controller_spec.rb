require 'rails_helper'
include GeojsonSupport

RSpec.describe Users::RegistrationsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'GET new' do
    context 'when logged out' do
      context 'without address in session' do
        before { get :new }

        it 'assigns no graetzl' do
          expect(assigns(:graetzl)).not_to be_present
        end

        it 'renders :address_form' do
          expect(response).to render_template(:address_form)
        end
      end
      context 'with address and graetzl in session' do
        let(:address) { build(:address) }
        let!(:graetzl) { create(:graetzl) }
        before do
          session[:address] = address.attributes
          session[:graetzl] = graetzl.id
          get :new
        end

        it 'assigns @graetzl' do
          expect(assigns(:graetzl)).to eq graetzl
        end

        it 'renders :new' do
          expect(response).to render_template(:new)
        end

        it 'clears session' do
          expect(session[:address]).to be nil
          expect(session[:graetzl]).to be nil
        end

        describe '@user' do
          subject(:user) { assigns(:user) }

          it 'gets assigned' do
            expect(user).not_to be_nil
          end

          it 'has address' do
            expect(user.address).to be_present
          end

          it 'has graetzl' do
            expect(user.graetzl).to eq graetzl
          end
        end
      end
    end
  end

  describe 'POST new' do
    let(:params) { { address: 'address_param' } }
    context 'without feature param' do
      before { post :new, params: params }

      it 'assigns @search_input with address_param' do
        expect(assigns(:search_input)).to eq 'address_param'
      end

      it 'assigns @address with nil attributes' do
        expect(assigns(:address)).to have_attributes(
          street_name: nil,
          street_number: nil,
          zip: nil,
          city: nil,
          coordinates: nil)
      end

      it 'puts address in session' do
        expect(session[:address]).to be_present
      end

      it 'assigns @graetzl with nil' do
        expect(assigns(:graetzl)).to eq nil
      end

      it 'assigns empty @graetzls' do
        expect(assigns(:graetzls)).to be_empty
      end

      it 'renders :graetzl' do
        expect(response).to render_template(:graetzl)
      end
    end
    context 'with feature param' do
      let!(:graetzl) { create(:graetzl) }
      let(:feature) { feature_hash(5,5) }
      before { params.merge!({ feature: feature.to_json }) }

      context 'when address matches single graetzl' do
        before { post :new, params: params }

        it 'assigns @graetzl' do
          expect(assigns(:graetzl)).to eq graetzl
        end

        it 'renders new' do
          expect(response).to render_template(:new)
        end

        it 'clears session' do
          expect(session[:address]).to be nil
          expect(session[:graetzl]).to be nil
        end

        describe '@user' do
          subject(:user) { assigns(:user) }

          it 'gets assigned' do
            expect(user).not_to be_nil
          end

          it 'has address' do
            expect(user.address).to be_present
          end

          it 'has graetzl' do
            expect(user.graetzl).to eq graetzl
          end
        end

        # it 'has right address from feature in session' do
        #   add_attr = Address.attributes_from_feature(feature.to_json)
        #   expect(session[:address]).to eq addr_attr
        # end
      end
      context 'when address matches multiple graetzl' do
        let!(:graetzl_1) { create(:graetzl) }
        let!(:graetzl_2) { create(:graetzl) }
        before { post :new, params: params }

        # it 'has right address from feature in session' do
        #   addr_attr = Address.attributes_from_feature(feature.to_json)
        #   expect(session[:address]).to eq addr_attr.stringify_keys
        # end

        it 'assigns @graetzls with all matching' do
          expect(assigns(:graetzls)).to include(graetzl, graetzl_1, graetzl_2)
        end

        it 'renders :graetzl' do
          expect(response).to render_template(:graetzl)
        end
      end
    end
  end

  describe 'GET graetzl' do

    it 'renders :graetzl when html request' do
      get :graetzl
      expect(response).to render_template(:graetzl)
    end
  end

  describe 'POST graetzl' do
    let!(:graetzl) { create(:graetzl) }
    before { post :graetzl, params: { graetzl_id: graetzl } }

    it 'clears session' do
      expect(session[:address]).to be nil
      expect(session[:graetzl]).to be nil
    end

    it 'renders :new' do
      expect(response).to render_template(:new)
    end

    describe '@user' do
      subject(:user) { assigns(:user) }

      it 'gets assigned' do
        expect(user).not_to be_nil
      end

      it 'has address' do
        expect(user.address).to be_present
      end

      it 'has graetzl' do
        expect(user.graetzl).to eq graetzl
      end
    end
  end

  describe 'POST create' do
    let(:address) { build(:address) }
    let!(:graetzl) { create(:graetzl) }
    let(:params) {
      {
        user: attributes_for(:user).merge(
        {
          address_attributes: address.attributes,
          graetzl_id: graetzl.id
        })
      }
    }

    context 'with all required attributes' do

      it 'creates new user' do
        expect{
          post :create, params: params
        }.to change(User, :count).by(1)
      end

      describe 'new user' do
        subject(:new_user) { User.last }
        before { post :create, params: params }

        it 'has graetzl' do
          expect(new_user.graetzl).to eq graetzl
        end

        it 'has address' do
          expect(new_user.address).to have_attributes(
            street_name: address.street_name,
            street_number: address.street_number,
            zip: address.zip,
            city: address.city,
            coordinates: address.coordinates,
            addressable_id: new_user.id,
            addressable_type: 'User')
        end

        it 'has no role' do
          expect(new_user.role).to eq nil
        end
      end
    end

    context 'with role business' do
      before { params.deep_merge!({ user: { role: :business } }) }

      describe 'new user' do
        subject(:new_user) { User.last }
        before { post :create, params: params }

        it 'has role business' do
          expect(new_user.business?).to eq true
        end
      end
    end
  end

  describe 'DELETE destroy' do
    context 'when logged out' do
      it 'redirects to login' do
        delete :destroy
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      let(:user) { create(:user) }
      before { sign_in user }

      it 'deletes user record' do
        expect{
          delete :destroy
        }.to change(User, :count).by(-1)
      end

      it 'redirects to root' do
        delete :destroy
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
