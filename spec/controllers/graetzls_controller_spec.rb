require 'rails_helper'

RSpec.describe GraetzlsController, type: :controller do
  let(:user) { create(:user) }
  let(:graetzl) { create(:graetzl) }

  describe 'GET show' do
    context 'when no current_user' do
      before { get :show, id: graetzl.id }

      it 'returns a 200 OK status' do
        expect(response).to be_success
        expect(response).to have_http_status(:ok)
      end

      it 'renders #show' do
        expect(response).to render_template(:show)
      end
    end

    context 'when current_user' do
      before do
        sign_in user
        get :show, id: graetzl.id
      end

      it 'returns a 200 OK status' do
        expect(response).to be_success
        expect(response).to have_http_status(:ok)
      end

      it 'renders #show' do
        expect(response).to render_template(:show)
      end
    end
  end

end
