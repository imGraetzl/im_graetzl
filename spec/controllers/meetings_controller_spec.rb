require 'rails_helper'

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
        attrs[:address_attributes] = attributes_for(:address)
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
    end
  end
end
