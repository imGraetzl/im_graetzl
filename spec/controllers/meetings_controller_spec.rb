require 'rails_helper'
include GeojsonSupport

RSpec.describe MeetingsController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  let(:user) { create(:user, graetzl: graetzl) }

  describe 'GET new' do

    context 'when no current_user' do
      it 'redirects to login_page' do
        get :new, { graetzl_id: graetzl.id }
        expect(response).to render_template(session[:new])
      end
    end

    context 'when current_user set' do
      before do
        sign_in user
        get :new, {graetzl_id: graetzl.id}
      end

      it 'renders #new' do        
        expect(response).to render_template(:new)
      end

      it 'assigns graetzl' do
        expect(assigns(:graetzl)).to eq(graetzl)
      end

      it 'builds new meeting and address' do
        expect(assigns(:meeting)).to be_a_new(Meeting)
        expect(assigns(:meeting).address).to be_a_new(Address)
      end
    end
  end


  describe 'POST create' do

    context 'when no current_user' do
      it 'redirects to login_page' do
        post :create, { graetzl_id: graetzl.id }
        expect(response).to render_template(session[:new])
      end
    end

    context 'when current_user set' do
      let(:attrs) { attributes_for(:meeting) }
      before do
        attrs[:address_attributes] = {}
        attrs[:address_attributes][:description] = ''
        sign_in user
      end

      it 'creates new meeting' do
        expect {
          post :create, graetzl_id: graetzl.id, meeting: attrs
        }.to change(Meeting, :count).by(1)
      end

      it 'puts current_user as initiator' do
        post :create, graetzl_id: graetzl.id, meeting: attrs
        going_to = Meeting.last.going_tos.last
        expect(going_to).to have_attributes(
          user: user,
          role: GoingTo::ROLES[:initator])
      end

      it 'puts current_user graetzl to meeting graetzls' do
        post :create, graetzl_id: graetzl.id, meeting: attrs
        expect(Meeting.last.graetzls.first).to eq(graetzl)
      end

      it 'adds empty address to meeting' do
        post :create, graetzl_id: graetzl.id, meeting: attrs
        expect(Meeting.last.address).to be_present
      end

      it 'adds address description' do
        attrs[:address_attributes][:description] = 'new_address_description'
        post :create, graetzl_id: graetzl.id, meeting: attrs
        expect(Meeting.last.address.description).to eq('new_address_description')
      end

      context 'when categories chosen' do
        before do
          5.times { create(:category) }
          attrs[:category_ids] = Category.all.map(&:id)
        end

        it 'adds categories to meeting' do
          post :create, graetzl_id: graetzl.id, meeting: attrs
          expect(assigns(:meeting).categories.size).to eq(5)
        end
      end

      context 'when address feature present' do
        before do
          sign_in user
        end

        it 'adds address from feature to meeting' do
          post :create, graetzl_id: graetzl.id, meeting: attrs, feature: esterhazygasse_hash.to_json
          address = Meeting.last.address
          expect(address.street_name).to eq('Esterházygasse')
        end

        it 'adds address description to meeting' do
          attrs[:address_attributes][:description] = 'new_address_description'
          post :create, graetzl_id: graetzl.id, meeting: attrs, feature: esterhazygasse_hash.to_json
          address = Meeting.last.address
          expect(address.street_name).to eq('Esterházygasse')
          expect(address.description).to eq('new_address_description')
        end
      end
    end
  end
end
