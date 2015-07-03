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

  describe 'POST toggle_website_notification' do

    context 'when no current_user' do
      it 'redirects to login' do
        post :toggle_website_notification
        expect(response).to render_template(session[:new])
      end
    end

    context 'signed in' do
      let(:user) { create(:user) }
      let(:type) { :new_meeting_in_graetzl }

      before { sign_in user }

      it 'toggles a single website notification setting' do
        expect(user.enabled_website_notification?(type)).to be_falsey  
        bitmask = User::WEBSITE_NOTIFICATION_TYPES[type][:bitmask]
        post :toggle_website_notification, :type => type
        user.reload
        expect(user.enabled_website_notification?(type)).to be_truthy
        post :toggle_website_notification, :type => type
        user.reload
        expect(user.enabled_website_notification?(type)).to be_falsey  
      end

      context 'when submitted bitmask is invalid' do
        let(:type) { 'blabla' }

        it 'returns 500' do
          post :toggle_website_notification, :type => type
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
