require 'rails_helper'

RSpec.describe WorkerController, type: :controller do

  describe 'POST truncate_db' do
    context 'when in worker env' do
      before do
        ENV['ALLOW_WORKER'] = 'true'
        post :truncate_db
      end

      it 'returns 200' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when no in worker env' do
      before do
        ENV['ALLOW_WORKER'] = ''
        post :truncate_db
      end

      it 'returns forbidden status' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
