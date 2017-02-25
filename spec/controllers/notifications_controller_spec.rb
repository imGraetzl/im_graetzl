require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  render_views false

  let(:user) do
    all_on = Notification.subclasses.inject(0) { |sum, k|k::BITMASK | sum }
    create(:user, enabled_website_notifications: all_on)
  end

  describe 'GET index' do
    context 'when logged out' do
      it 'redirects to login' do
        get :index
        expect(response).to render_template(session[:new])
      end
    end
    context 'when logged in' do
      before do
        stub_const("NotificationsController::NOTIFICATIONS_PER_PAGE", 3)
        create_list(:notification,
                    NotificationsController::NOTIFICATIONS_PER_PAGE * 2,
                    user: user,
                    display_on_website: true)
        sign_in user
      end
      describe 'initial request' do
        before { get :index, xhr: true }

        it 'assigns @page to 1' do
          expect(assigns :page).to eq 1
        end
        it 'assigns @notifications with first page' do
          page_size = NotificationsController::NOTIFICATIONS_PER_PAGE
          expect(assigns :notifications).to eq user.website_notifications.order("created_at DESC").limit(page_size)
        end
        it 'does not mark notifications as seen' do
          expect(assigns(:notifications).map(&:seen)).to all(be_falsy)
        end
        it "assigns not more than #{NotificationsController::NOTIFICATIONS_PER_PAGE} notifications" do
          expect(assigns(:notifications).count).to be <= NotificationsController::NOTIFICATIONS_PER_PAGE
        end
        it "orders assigned notifications, youngest first" do
          sorted = assigns(:notifications).sort { |a,b| b.created_at <=> a.created_at }
          expect(assigns(:notifications)).to eq(sorted)
        end
        it "assigns @more_notifications to true" do
          expect(assigns(:more_notifications)).to be_truthy
        end
        it 'renders index.js' do
          expect(response.content_type).to eq 'text/javascript'
          expect(response).to render_template(:index)
        end
      end
      describe 'pagination request' do
        before { get :index, params: { page: '2' }, xhr: true }

        it 'assigns @page = 2' do
          expect(assigns :page).to eq 2
        end
        it 'assigns @notifications with next page' do
          page_size = NotificationsController::NOTIFICATIONS_PER_PAGE
          expect(assigns :notifications).to eq user.website_notifications.order("created_at DESC").offset(page_size).limit(page_size)
        end
        it 'marks @notifications as seen' do
          expect(assigns(:notifications).map(&:seen)).to all(be_truthy)
        end
        it "assigns @more_notifications to false" do
          expect(assigns(:more_notifications)).to be_falsy
        end
      end
    end
  end

  describe 'POST mark_as_seen' do
    let!(:notifications) { create_list(:notification, 10) }
    let(:params) {
      { ids: notifications.map(&:id).to_json } }

    before { sign_in create(:user) }

    it 'marks notifications as seen' do
      expect(notifications.map(&:seen)).to all(be false)
      post :mark_as_seen, params: params, xhr: true
      notifications.map{|n| n.reload}
      expect(notifications.map(&:seen)).to all(be true)
    end
    it 'renders mark_as_seen.js' do
      post :mark_as_seen, params: params, xhr: true
      expect(response.content_type).to eq 'text/javascript'
      expect(response).to render_template(:mark_as_seen)
    end
  end
end
