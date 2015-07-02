require 'rails_helper'

RSpec.describe NotificationSettingsController, type: :controller do
  describe 'GET index' do
    context 'when no current_user' do
      it 'redirects to login' do
        get :index
        expect(response).to render_template(session[:new])
      end
    end
  end
end
