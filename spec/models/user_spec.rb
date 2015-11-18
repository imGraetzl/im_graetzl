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

  describe 'callbacks' do
    let(:user) { create(:user) }

    describe 'before_destroy' do
      before do
        3.times do
          activity = create(:activity, trackable: create(:meeting), owner: user, key: 'meeting.go_to')
          3.times{ create(:notification, activity: activity) }
        end
      end

      it 'destroys associated activity and notifications' do
        expect(PublicActivity::Activity.count).to eq 3
        expect(Notification.count).to eq 9

        user.destroy

        expect(Notification.count).to eq 0
        expect(PublicActivity::Activity.count).to eq 0
      end
    end

    describe 'before_validation' do
      context 'when username one word' do
        let(:user) { build(:user, username: ' name ') }

        it 'strips whitespaces on beginning and end' do
          expect{
            user.save
          }.to change{user.username.length}.from(6).to(4)
        end
      end
      context 'when username more words' do
        let(:user) { build(:user, username: ' first  second ') }

        it 'strips any double whitespaces' do
          expect{
            user.save
          }.to change{user.username}.from(' first  second ').to('first second')
        end
      end
    end
  end

  describe 'macros' do
    let(:user) { build_stubbed(:user) }

    it 'has friendly_id' do
      expect(user).to respond_to(:slug)
    end

    describe 'role' do

      it 'has one' do
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

    describe 'photos' do

      it 'has avatar' do
        expect(user).to respond_to(:avatar)
      end

      it 'has avatar_content_type' do
        expect(user).to respond_to(:avatar_content_type)
      end

      it 'has cover_photo' do
        expect(user).to respond_to(:cover_photo)
      end

      it 'has cover_photo_content_type' do
        expect(user).to respond_to(:cover_photo_content_type)
      end
    end
  end

  describe 'attributes' do
    let(:user) { build(:user) }

    it 'has bio' do
      expect(user).to respond_to(:bio)
    end

    it 'has website' do
      expect(user).to respond_to(:website)
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

    it 'has wall_comments' do
      expect(user).to respond_to(:wall_comments)
    end

    describe 'destroy associated records' do
      describe 'address' do
        before { user.create_address(attributes_for(:address)) }

        it 'has address' do
          expect(user.address).not_to be_nil
        end

        it 'destroys address with user' do
          address = user.address
          expect(Address.find(address.id)).not_to be_nil
          user.destroy
          expect(Address.find_by_id(address.id)).to be_nil
        end
      end

      describe 'going_tos' do
        before { 3.times{create(:going_to, user: user, meeting: create(:meeting))} }

        it 'has going_tos' do
          expect(user.going_tos).not_to be_empty
        end

        it 'destroys going_tos' do
          going_tos = user.going_tos
          going_tos.each do |going_to|
            expect(GoingTo.find(going_to.id)).not_to be_nil
          end
          user.destroy
          going_tos.each do |going_to|
            expect(GoingTo.find_by_id(going_to.id)).to be_nil
          end
        end
      end

      describe 'notifications' do
        before do
          3.times{create(:notification,
                          user: user,
                          activity: build_stubbed(:activity))}
        end

        it 'has notifications' do
          expect(user.notifications).not_to be_empty
        end

        it 'destroys notifications' do
          notifications = user.notifications
          notifications.each do |n|
            expect(Notification.find(n.id)).not_to be_nil
          end
          user.destroy
          notifications.each do |n|
            expect(Notification.find_by_id(n.id)).to be_nil
          end
        end
      end

      describe 'posts' do
        before { 3.times{create(:post, author: user)} }

        it 'has posts' do
          expect(user.posts).not_to be_empty
        end

        it 'destroys posts' do
          posts = user.posts
          posts.each do |p|
            expect(Post.find(p.id)).not_to be_nil
          end
          user.destroy
          posts.each do |p|
            expect(Post.find_by_id(p.id)).to be_nil
          end
        end
      end

      describe 'comments' do
        before { 3.times{create(:comment, user: user)} }

        it 'has comments' do
          expect(user.comments).not_to be_empty
        end

        it 'destroys comments' do
          comments = user.comments
          comments.each do |comment|
            expect(Comment.find(comment.id)).not_to be_nil
          end
          user.destroy
          comments.each do |comment|
            expect(Comment.find_by_id(comment.id)).to be_nil
          end
        end
      end

      describe 'location_ownerships' do
        before { 3.times{create(:location_ownership, user: user)} }

        it 'has location_ownerships' do
          expect(user.location_ownerships).not_to be_empty
        end

        it 'destroys location_ownerships' do
          location_ownerships = user.location_ownerships
          location_ownerships.each do |ownership|
            expect(LocationOwnership.find(ownership.id)).not_to be_nil
          end
          user.destroy
          location_ownerships.each do |ownership|
            expect(LocationOwnership.find_by_id(ownership.id)).to be_nil
          end
        end
      end

      describe 'wall_comments' do
        before { 3.times{create(:comment, commentable: user)} }

        it 'has wall_comments' do
          expect(user.wall_comments).not_to be_empty
        end

        it 'destroys wall_comments' do
          wall_comments = user.wall_comments
          wall_comments.each do |comment|
            expect(Comment.find(comment.id)).not_to be_nil
          end
          user.destroy
          wall_comments.each do |comment|
            expect(Comment.find_by_id(comment.id)).to be_nil
          end
        end
      end
    end
  end

  describe "mail notifications", job: true do
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
        create(:notification, user: user, bitmask: bitmask, display_on_website: true)
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
