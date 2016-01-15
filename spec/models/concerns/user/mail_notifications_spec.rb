require 'rails_helper'

RSpec.describe User::MailNotifications, job: true do
  let(:user) { create(:user, :graetzl => create(:graetzl)) }
  let(:meeting) { create(:meeting, graetzl: user.graetzl) }
  let(:type) { Notifications::NewMeeting }

  around(:each) do |example|
    PublicActivity.with_tracking do
      example.run
    end
  end

  # describe "daily summary" do
  #   before {  user.enable_mail_notification(type, :daily) }
  #
  #   it "creates a send notification mail job" do
  #     activity = meeting.create_activity :create, owner: create(:user)
  #     user.notifications.reload
  #     expect(user.notifications_of_the_day).to include(user.notifications.last)
  #   end
  #
  #   context "when notification is older than a day" do
  #     it "it is not sent" do
  #       spy = class_double("SendMailNotificationJob", perform_later: nil).as_stubbed_const
  #       activity = meeting.create_activity :create, owner: create(:user)
  #       n = user.notifications.last
  #       n.created_at = 2.days.ago
  #       n.save!
  #       user.notifications.reload
  #       expect(user.notifications_of_the_day.collect(&:id)).not_to include(user.notifications.last.id)
  #     end
  #   end
  # end
  #
  # describe "weekly summary" do
  #   before {  user.enable_mail_notification(type, :weekly) }
  #
  #   it "creates a send notification mail job" do
  #     activity = meeting.create_activity :create, owner: create(:user)
  #     user.notifications.reload
  #     expect(user.notifications_of_the_week.collect(&:id)).to include(user.notifications.last.id)
  #   end
  #
  #   context "when notification is older than a week" do
  #     it "it is not passed to the daily notification mail job" do
  #       spy = class_double("SendMailNotificationJob", perform_later: nil).as_stubbed_const
  #       activity = meeting.create_activity :create, owner: create(:user)
  #       n = user.notifications.last
  #       n.created_at = 8.days.ago
  #       n.save!
  #       user.notifications.reload
  #     expect(user.notifications_of_the_week.collect(&:id)).not_to include(user.notifications.last.id)
  #     end
  #   end
  # end

  describe "enabling" do
    before do
      Notification.subclasses.each do |klass|
        bitmask = klass::BITMASK
        create(:notification, user: user, bitmask: bitmask)
      end
    end
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
