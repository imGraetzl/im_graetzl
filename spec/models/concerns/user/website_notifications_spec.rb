require 'rails_helper'

RSpec.describe User::WebsiteNotifications do
  let(:user) { create(:user, :graetzl => create(:graetzl)) }

  before do
    Notification.subclasses.each do |klass|
      bitmask = klass::BITMASK
      create(:notification, user: user, bitmask: bitmask, display_on_website: true)
    end
  end

  describe "enabling" do
    it "can be enabled for a specific type" do
      type = Notifications::NewMeeting
      expect(user.enabled_website_notification?(type)).to be_falsey
      user.enable_website_notification(type)
      expect(user.enabled_website_notification?(type)).to be_truthy
    end

    it "returns only enabled notifications" do
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

  it "can be toggled for a specific type" do
    type = Notifications::NewMeeting
    expect(user.enabled_website_notification?(type)).to be_falsey
    user.toggle_website_notification(type)
    expect(user.enabled_website_notification?(type)).to be_truthy
    user.toggle_website_notification(type)
    expect(user.enabled_website_notification?(type)).to be_falsey
  end
end
