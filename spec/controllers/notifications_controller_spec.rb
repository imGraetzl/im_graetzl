require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  render_views false
  
  let(:user) do
    all_on = Notification::TYPES.keys.inject(0) { |sum, k| Notification::TYPES[k][:bitmask] | sum }
    create(:user, enabled_website_notifications: all_on)
  end

  describe 'GET index' do
    context 'when no current_user' do
      it 'redirects to login' do
        get :index
        expect(response).to render_template(session[:new])
      end
    end

    context 'signed in' do
      before do
        stub_const("NotificationsController::NOTIFICATIONS_PER_PAGE", 3)
        (NotificationsController::NOTIFICATIONS_PER_PAGE + 3).times do
          create(:notification, user: user, display_on_website: true)
        end

        sign_in user
        xhr :get, :index
      end

      it "assigns not more den #{NotificationsController::NOTIFICATIONS_PER_PAGE} notifications" do
        expect(assigns(:notifications).count).to be <= NotificationsController::NOTIFICATIONS_PER_PAGE
      end

      it "orders assigned notifications, youngest first" do
        sorted = assigns(:notifications).sort { |a,b| b.created_at <=> a.created_at }
        expect(assigns(:notifications)).to eq(sorted)

      end

      context "when there are more notifications" do
        it "assigns @more_notifications to true" do
          expect(assigns(:more_notifications)).to be_truthy
        end
      end

      context "when there are not more notifications" do
        it "assigns @more_notifications to false" do
          xhr :get, :index, page: "2"
          expect(assigns(:more_notifications)).to be_falsy
        end
      end

      it "assigns correct page" do
        page_size = NotificationsController::NOTIFICATIONS_PER_PAGE
        current = user.website_notifications.order("created_at DESC").limit(page_size).collect(&:id).sort
        expect(assigns(:notifications).collect(&:id).sort).to eq(current)

        current = user.website_notifications.order("created_at DESC").offset(page_size).limit(page_size).collect(&:id).sort
        xhr :get, :index, page: "2"
        expect(assigns(:notifications).collect(&:id).sort).to eq(current)
      end

      it 'returns a 200 OK status' do
        expect(response).to be_success
      end
    end
  end
end
