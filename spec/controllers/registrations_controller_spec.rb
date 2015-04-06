require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @graetzl = create(:graetzl)
  end

  describe 'POST user_registration' do
    let(:attrs) { attributes_for(:user) }

    context 'with address and graetzl' do
      before do
        attrs[:address_attributes] = attributes_for(:address)
        attrs[:graetzl_attributes] = { name: @graetzl.name }
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
        expect(User.last.graetzl).to eq(@graetzl)
      end
    end

    context 'with only graetzl' do
      before do
        attrs[:graetzl_attributes] = { name: @graetzl.name }
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