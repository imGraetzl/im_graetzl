require 'rails_helper'

RSpec.describe User::Notifiable do
  let(:user) { create(:user, :graetzl => create(:graetzl)) }

  describe 'website notifications' do
    before do
      Notification.subclasses.each do |klass|
        create(:notification, user: user, bitmask: klass::BITMASK, display_on_website: true)
      end
    end

    describe 'enabling' do
      let(:type) { Notifications::NewMeeting }

      it 'updates enabled_website_notifications' do
        expect{
          user.enable_website_notification type
          user.reload
        }.to change(user, :enabled_website_notifications)
      end

      it 'makes type pass through filter' do
        expect(user.enabled_website_notification? type).to be_falsey
        user.enable_website_notification type
        expect(user.enabled_website_notification? type).to be_truthy
      end
    end

    describe 'toggling' do
      let(:type) { Notifications::NewMeeting }

      it 'updates enabled_website_notifications' do
        expect{
          user.toggle_website_notification type
        }.to change(user, :enabled_website_notifications)
      end

      it "can be toggled for a specific type" do
        expect(user.enabled_website_notification?(type)).to be_falsey
        user.toggle_website_notification(type)
        expect(user.enabled_website_notification?(type)).to be_truthy
        user.toggle_website_notification(type)
        expect(user.enabled_website_notification?(type)).to be_falsey
      end
    end

    describe '#website_notifications' do
      let!(:other_notification) { create(:notification,
        user: user,
        bitmask: Notifications::NewMeeting::BITMASK,
        display_on_website: false)
      }

      it 'retuns only for display_on_website' do
        user.enable_website_notification Notifications::NewMeeting
        expect(user.website_notifications).not_to include(other_notification)
      end

      it "returns only enabled types" do
        expect(user.new_website_notifications_count).to eq(0)
        user.enable_website_notification Notifications::NewMeeting
        expect(user.new_website_notifications_count).to eq(1)
        user.enable_website_notification Notifications::NewLocationPost
        expect(user.new_website_notifications_count).to eq(2)
        user.enable_website_notification Notifications::AttendeeInUsersMeeting
        user.toggle_website_notification Notifications::NewMeeting
        expect(user.new_website_notifications_count).to eq(2)
        user.toggle_website_notification Notifications::AttendeeInUsersMeeting
        expect(user.new_website_notifications_count).to eq(1)
      end
    end
  end

  describe 'mail notifications' do
    before do
      Notification.subclasses.each do |klass|
        create(:notification, user: user, bitmask: klass::BITMASK)
      end
    end

    describe 'enabling' do
      let(:type) { Notifications::NewMeeting }

      it "can be enabled for a specific type" do
        expect(user.enabled_mail_notification?(type, :daily)).to be_falsey
        user.enable_mail_notification(type, :daily)
        expect(user.enabled_mail_notification?(type, :daily)).to be_truthy
        expect(user.enabled_mail_notification?(type, :weekly)).to be_falsey
        user.enable_mail_notification(type, :weekly)
        expect(user.enabled_mail_notification?(type, :weekly)).to be_truthy
        expect(user.enabled_mail_notification?(type, :immediate)).to be_falsey
        user.enable_mail_notification(type, :immediate)
        expect(user.enabled_mail_notification?(type, :immediate)).to be_truthy
      end

      it "can only be set to either immediate, daily, or weekly" do
        expect(user.enabled_mail_notification?(type, :daily)).to be_falsey
        user.enable_mail_notification(type, :daily)
        expect(user.enabled_mail_notification?(type, :daily)).to be_truthy
        user.enable_mail_notification(type, :weekly)
        expect(user.enabled_mail_notification?(type, :weekly)).to be_truthy
        expect(user.enabled_mail_notification?(type, :daily)).to be_falsey
      end
    end
  end
end
