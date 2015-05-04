require 'rails_helper'

RSpec.describe MeetingsController, type: :controller do
  let(:graetzl) { create(:graetzl) }
  let(:user) { create(:user, graetzl: graetzl) }

  describe 'GET new' do
    context 'without current_user' do
      it 'renders login page' do
        get :new, { graetzl_id: graetzl.id }
        expect(response).to render_template(session[:new])
      end
    end

    context 'with current_user' do
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

  describe 'POST create' do
    context 'without current_user' do
      it 'renders login page' do
        post :create, { graetzl_id: graetzl.id }
        expect(response).to render_template(session[:new])
      end
    end

    context 'with current_user' do
      let(:attrs) { attributes_for(:meeting) }
      before { sign_in user }

      it 'creates new meeting' do
        expect {
          post :create, graetzl_id: graetzl.id, meeting: attrs
        }.to change(Meeting, :count).by(1)
      end

      it 'assigns meeting for current_user in home_graetzl' do
        post :create, graetzl_id: graetzl.id, meeting: attrs
        expect(assigns(:meeting).user_initialized).to eq(user)
        expect(assigns(:meeting).graetzls.first).to eq(graetzl)
      end

      context 'with categories' do
        before do
          5.times { create(:category) }
          attrs[:category_ids] = Category.all.map(&:id)
        end

        it 'assigns meeting with categories' do
          post :create, graetzl_id: graetzl.id, meeting: attrs
          expect(assigns(:meeting).categories.size).to eq(5)
        end
      end
    end
  end
end
