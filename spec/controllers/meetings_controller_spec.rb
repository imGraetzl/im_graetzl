require 'rails_helper'

RSpec.describe MeetingsController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  let(:user) { create(:user, graetzl: graetzl) }

  describe 'GET new' do
    context 'without authenticated user' do
      it 'renders login page' do
        get :new, {graetzl_id: graetzl.id}
        expect(response).to render_template(session[:new])
      end
    end

    context 'with user authenticated' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:admin]
        sign_in user
        get :new, {graetzl_id: graetzl.id}
      end

      it 'renders meeting_new' do        
        expect(response).to render_template(:new)
      end

      it 'builds meeting for user' do
        expect(assigns(:meeting).user_initialized).to eq (user)
      end

      it 'assigns meeting, graetzl and address' do
        expect(assigns(:meeting)).not_to be_nil
        expect(assigns(:graetzl)).to eq(graetzl)
        expect(assigns(:meeting).graetzls).to eq([graetzl])
        expect(assigns(:meeting).address).not_to be_nil
      end
    end
  end

  # describe 'POST create' do
  #   let(:attrs) { attributes_for(:meeting_attributes) }
  #   before { sign_in user }

  #   context 'with address given' do
  #     before do
  #       attrs[:address_attributes] = attributes_for(:address)
  #     end

  #     it 'creates new meeting' do
  #       expect {
  #         post :create, graetzl_id: graetzl.id, meeting: attrs
  #       }.to change(Meeting, :count).by(1)
  #     end

  #     it 'renders meeting page' do
  #       post :create, graetzl_id: graetzl.id, meeting: attrs
  #       expect(response).to redirect_to(graetzl_meeting_url(assigns(:graetzl), assigns(:meeting)))
  #     end
  #   end
  # end
end
