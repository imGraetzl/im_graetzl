require 'rails_helper'

RSpec.describe NotificationSettingsController, type: :controller do

  describe 'POST toggle_website_notification' do
    context 'when no current_user' do
      it 'redirects to login' do
        post :toggle_website_notification
        expect(response).to render_template(session[:new])
      end
    end

    context 'signed in' do
      let(:user) { create(:user) }
      let(:type) { Notifications::NewMeeting }

      before { sign_in user }

      it 'toggles a single website notification setting' do
        expect(user.enabled_website_notification?(type)).to be_falsey
        post :toggle_website_notification, params: { type: type }
        user.reload
        expect(user.enabled_website_notification?(type)).to be_truthy
        post :toggle_website_notification, params: { type: type }
        user.reload
        expect(user.enabled_website_notification?(type)).to be_falsey
      end

      context 'when submitted type is invalid' do
        let(:type) { 'blabla' }

        it 'returns 500' do
          post :toggle_website_notification, params: { type: type }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end

  describe 'POST change_mail_notification' do
    context 'when no current_user' do
      it 'redirects to login' do
        post :change_mail_notification
        expect(response).to render_template(session[:new])
      end
    end

    context 'signed in' do
      let(:user) { create(:user) }
      let(:type) { Notifications::NewMeeting }
      let(:interval) { :daily }

      before do
        user.daily_mail_notifications = 0
        sign_in user
      end

      it 'changes a single mail notification setting' do
        expect(user.enabled_mail_notification?(type, interval)).to be_falsey
        post :change_mail_notification, params: { type: type, interval: interval }
        user.reload
        expect(user.enabled_mail_notification?(type, interval)).to be_truthy
      end

      it "turns off a single mail notification" do
        user.enable_mail_notification(type, interval)
        expect(user.enabled_mail_notification?(type, interval)).to be_truthy
        post :change_mail_notification, params: { type: type, interval: "off" }
        user.reload
        expect(user.enabled_mail_notification?(type, interval)).to be_falsey

      end

      context 'when submitted type is invalid' do
        let(:type) { 'blabla' }

        it 'returns 500' do
          post :toggle_website_notification, params: { type: type }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
