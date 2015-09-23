require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin) { create(:user_admin) }

  before { sign_in admin }

  describe 'GET index' do
    before { get :index }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @users' do
      expect(assigns(:users)).not_to be_nil
    end

    it 'renders :index' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET show' do
    let(:user) { create(:user) }
    before { get :show, id: user }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @user' do
      expect(assigns(:user)).to eq user
    end

    it 'renders :show' do
      expect(response).to render_template(:show)
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @user' do
      expect(assigns(:user)).to be_a_new(User)
    end

    it 'renders :new' do
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    let(:user) { build(:user,
      graetzl: create(:graetzl),
      bio: 'bio',
      website: 'http://google.de',
      newsletter: true) }
    let(:params) {
      {
        user: {
          graetzl_id: user.graetzl.id,
          username: user.username,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          password: user.password,
          role: user.role,
          bio: user.bio,
          website: user.website,
          newsletter: user.newsletter
        }
      }
    }

    context 'with basic attributes' do

      it 'creates new user record' do
        expect{
          post :create, params
        }.to change{User.count}.by(1)
      end

      it 'assigns attributes to user' do
        post :create, params
        u = User.last
        expect(u).to have_attributes(
          username: user.username,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          bio: user.bio,
          role: user.role,
          website: user.website,
          newsletter: user.newsletter)
      end
    end

    context 'with address' do
      let(:address) { build(:address) }
      before do
        params[:user].merge!(address_attributes: {
          street_name: address.street_name,
          street_number: address.street_number,
          zip: address.zip,
          city: address.city,
          coordinates: address.coordinates
          })
      end

      it 'creates new user record' do
        expect{
          post :create, params
        }.to change{User.count}.by(1)
      end

      it 'creates new address record' do
        expect{
          post :create, params
        }.to change{Address.count}.by(1)
      end

      it 'redirects_to new user page' do
        post :create, params
        new_user = User.last
        expect(response).to redirect_to(admin_user_path(new_user))
      end

      describe 'new user' do
        before { post :create, params }
        subject(:new_user) { User.last }

        it 'is has address' do
          expect(new_user.address).not_to be_nil
        end

        it 'assigns address_attributes to user' do
          expect(Address.last).to have_attributes(
            street_name: address.street_name,
            street_number: address.street_number,
            zip: address.zip,
            city: address.city,
            coordinates: address.coordinates)
        end
      end
    end
  end

  describe 'GET edit' do
    let(:user) { create(:user) }
    before { get :edit, id: user }

    it 'returns success' do
      expect(response).to have_http_status(200)
    end

    it 'assigns @user' do
      expect(assigns(:user)).to eq user
    end

    it 'renders :edit' do
      expect(response).to render_template(:edit)
    end
  end

  describe 'PATCH update' do
    let(:user) { create(:user) }
    let(:new_user) { build(:user,
      graetzl: create(:graetzl),
      bio: 'bio',
      website: 'http://google.de',
      newsletter: true) }
    let(:params) {
      {
        id: user,
        user: {
          graetzl_id: new_user.graetzl.id,
          username: new_user.username,
          first_name: new_user.first_name,
          last_name: new_user.last_name,
          email: new_user.email,
          role: new_user.role,
          bio: new_user.bio,
          website: new_user.website,
          newsletter: new_user.newsletter
        }
      }
    }

    context 'with basic attributes' do
      before do
        patch :update, params
        user.reload
      end

      it 'redirects to user page' do
        expect(response).to redirect_to(admin_user_path(user))
      end

      it 'updates user attributes' do
        expect(user).to have_attributes(
          graetzl_id: new_user.graetzl.id,
          username: new_user.username,
          first_name: new_user.first_name,
          last_name: new_user.last_name,
          email: new_user.email,
          role: new_user.role,
          bio: new_user.bio,
          website: new_user.website,
          newsletter: new_user.newsletter)
      end
    end

    context 'with address' do
      let(:address) { build(:address) }
      before do
        params[:user].merge!(address_attributes: {
          street_name: address.street_name,
          street_number: address.street_number,
          zip: address.zip,
          city: address.city,
          coordinates: address.coordinates
          })
        patch :update, params
        user.reload
      end

      it 'updates user_address_attributes' do
        expect(user.address).to have_attributes(
          street_name: address.street_name,
          street_number: address.street_number,
          zip: address.zip,
          city: address.city,
          coordinates: address.coordinates)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:user) { create(:user) }

    it 'deletes user record' do
      expect{
        delete :destroy, id: user
      }.to change{User.count}.by(-1)
    end

    it 'redirects_to index page' do
      delete :destroy, id: user
      expect(response).to redirect_to(admin_users_path)
    end
  end
end