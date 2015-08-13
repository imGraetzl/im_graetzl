require 'rails_helper'

RSpec.describe User, type: :model do
  
  it 'has a valid factory' do
    expect(build_stubbed(:user)).to be_valid
  end

  describe 'validations' do
    it 'invalid without username' do
      expect(build(:user, username: nil)).not_to be_valid
    end

    it 'invalid with dublicate username' do
      first_user = create(:user)
      expect(build(:user, username: first_user.username)).not_to be_valid
    end

    it 'invalid without first_name' do
      expect(build(:user, first_name: nil)).not_to be_valid
    end

    it 'invalid without last_name' do
      expect(build(:user, last_name: nil)).not_to be_valid
    end

    it 'invalid without graetzl' do
      expect(build(:user, graetzl: nil)).not_to be_valid
    end
  end

  describe 'attributes' do
    let(:user) { build_stubbed(:user) }

    describe 'role' do

      it 'has role' do
        expect(user).to respond_to(:role)
      end

      context 'when admin' do
        before { user.role = :admin }

        it 'responds #admin? true' do
          expect(user.admin?).to eq(true)
        end

        it 'responds #business? false' do
          expect(user.business?).to eq(false)
        end
      end

      context 'when business' do
        before { user.role = :business }

        it 'responds #business? true' do
          expect(user.business?).to eq(true)
        end

        it 'responds #admin? false' do
          expect(user.admin?).to eq(false)
        end
      end
    end
  end

  describe 'associations' do
    let(:user) { create(:user) }

    it 'has address' do
      expect(user).to respond_to(:address)
    end

    it 'has graetzl' do
      expect(user).to respond_to(:graetzl)
    end

    it 'has meetings' do
      expect(user).to respond_to(:meetings)
    end

    it 'has posts' do
      expect(user).to respond_to(:posts)
    end

    it 'has locations' do
      expect(user).to respond_to(:locations)
    end

    it 'has comments' do
      expect(user).to respond_to(:comments)
    end

    describe 'avatar' do

      it 'has avatar' do
        expect(user).to respond_to(:avatar)
      end

      it 'has avatar_content_type' do
        expect(user).to respond_to(:avatar_content_type)
      end
    end

    describe 'destroy associated records' do
      before { user.create_address(attributes_for(:address)) }

      it 'has address' do
        expect(user.address).not_to be_nil
      end

      it 'destroys address with user' do
        address = user.address
        user.destroy
        expect(Address.find_by_id(address.id)).to be_nil
      end
    end
  end

  describe "mail notifications" do
    let(:user) { create(:user, :graetzl => create(:graetzl)) }
    let(:meeting) { create(:meeting, graetzl: user.graetzl) }
    let(:type) { :new_meeting_in_graetzl }

    around(:each) do |example|
      PublicActivity.with_tracking do
        example.run
      end
    end

    describe "daily summary" do
      before {  user.enable_mail_notification(type, :daily) }

      it "creates a send notification mail job" do
        activity = meeting.create_activity :create, owner: create(:user)
        user.notifications.reload
        expect(user.notifications_of_the_day.collect(&:id)).to include(user.notifications.last.id)
      end

      context "when notification is older than a day" do
        it "it is not sent" do
          spy = class_double("SendMailNotificationJob", perform_later: nil).as_stubbed_const
          activity = meeting.create_activity :create, owner: create(:user)
          n = user.notifications.last
          n.created_at = 2.days.ago
          n.save!
          user.notifications.reload
          expect(user.notifications_of_the_day.collect(&:id)).not_to include(user.notifications.last.id)
        end
      end
    end

    describe "weekly summary" do
      before {  user.enable_mail_notification(type, :weekly) }

      it "creates a send notification mail job" do
        activity = meeting.create_activity :create, owner: create(:user)
        user.notifications.reload
        expect(user.notifications_of_the_week.collect(&:id)).to include(user.notifications.last.id)
      end

      context "when notification is older than a week" do
        it "it is not passed to the daily notification mail job" do
          spy = class_double("SendMailNotificationJob", perform_later: nil).as_stubbed_const
          activity = meeting.create_activity :create, owner: create(:user)
          n = user.notifications.last
          n.created_at = 8.days.ago
          n.save!
          user.notifications.reload
        expect(user.notifications_of_the_week.collect(&:id)).not_to include(user.notifications.last.id)
        end
      end
    end

    describe "enabling" do
      before do
        Notification::TYPES.keys.each do |type|
          bitmask = Notification::TYPES[type][:bitmask]
          create(:notification, user: user, bitmask: bitmask)
        end
      end
      let(:type) { :new_meeting_in_graetzl }

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

  describe "website_notifications" do
    let(:user) { create(:user, :graetzl => create(:graetzl)) }
    before do
      Notification::TYPES.keys.each do |type|
        bitmask = Notification::TYPES[type][:bitmask]
        create(:notification, user: user, bitmask: bitmask)
      end
    end

    describe "enabling" do
      it "can be enabled for a specific type" do
        type = :new_meeting_in_graetzl
        expect(user.enabled_website_notification?(type)).to be_falsey  
        user.enable_website_notification(type)
        expect(user.enabled_website_notification?(type)).to be_truthy
      end

      it "returns only enabled notifications" do
        expect(user.new_website_notifications_count).to eq(0)
        user.enable_website_notification(:new_meeting_in_graetzl)
        expect(user.new_website_notifications_count).to eq(1)
        user.enable_website_notification(:new_post_in_graetzl)
        expect(user.new_website_notifications_count).to eq(2)
        user.enable_website_notification(:another_attendee)
        user.toggle_website_notification(:new_meeting_in_graetzl)
        expect(user.new_website_notifications_count).to eq(2)
        user.toggle_website_notification(:another_attendee)
        expect(user.new_website_notifications_count).to eq(1)
      end
    end

    it "can be toggled for a specific type" do
      type = :new_meeting_in_graetzl
      expect(user.enabled_website_notification?(type)).to be_falsey  
      user.toggle_website_notification(type)
      expect(user.enabled_website_notification?(type)).to be_truthy
      user.toggle_website_notification(type)
      expect(user.enabled_website_notification?(type)).to be_falsey  
    end
  end
end
