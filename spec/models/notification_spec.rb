require 'rails_helper'

RSpec.describe Notification, type: :model, job: true do
  around(:each) do |example|
    PublicActivity.with_tracking do
      example.run
    end
  end

  let(:user) { create(:user) }
  let(:meeting) { create(:meeting) }

  it 'has a valid factory' do
    expect(build_stubbed(:notification)).to be_valid
  end

  describe "associations" do
    let(:notification) { create(:notification) }

    it "has an activity" do
      expect(notification).to respond_to(:activity)
    end

    it "has a user" do
      expect(notification).to respond_to(:user)
    end
  end

  describe "a new meeting in graetzl" do
    before { user.enable_website_notification Notifications::NewMeeting }
    context "when user is from the same graetzl" do
      let(:user) { create(:user, graetzl: meeting.graetzl) }

      it "user is notified" do
        expect(user.notifications.to_a).to be_empty
        meeting.create_activity :create, owner: create(:user)
        user.notifications.reload
        expect(user.notifications.to_a).to_not be_empty
      end
    end

    context "when user is NOT from the same graetzl" do
      let(:user) { create(:user, graetzl: create(:graetzl)) }

      it "user is NOT notified" do
        meeting.create_activity :create, owner: create(:user)
        expect(user.notifications.to_a).to be_empty
      end
    end
  end

  describe "update of meeting" do
    let(:user) { create(:user, graetzl: meeting.graetzl) }
    before { user.enable_website_notification Notifications::MeetingUpdated }

    context "when user attends the meeting" do
      let!(:going_to) { create(:going_to,
                               user: user,
                               meeting: meeting,
                               role: GoingTo.roles[:attendee]) }

      it "user is notified" do
        expect(user.notifications.to_a).to be_empty
        meeting.create_activity :update, owner: create(:user)
        user.notifications.reload
        expect(user.notifications.to_a).to_not be_empty
      end
    end

    context "when user does not attend meeting" do
      it "user is NOT notified" do
        meeting.create_activity :update, owner: create(:user)
        expect(user.notifications.to_a).to be_empty
      end
    end
  end

  describe "cancel of meeting" do
    let(:user) { create(:user, graetzl: meeting.graetzl) }
    before { user.enable_website_notification Notifications::MeetingCancelled }

    context "when user attends the meeting" do
      let!(:going_to) { create(:going_to,
                               user: user,
                               meeting: meeting,
                               role: GoingTo.roles[:attendee]) }

      it "user is notified" do
        expect(user.notifications.to_a).to be_empty
        meeting.create_activity :cancel, owner: create(:user)
        user.notifications.reload
        expect(user.notifications.to_a).to_not be_empty
      end
    end

    context "when user does not attend meeting" do
      it "user is NOT notified" do
        meeting.create_activity :cancel, owner: create(:user)
        expect(user.notifications.to_a).to be_empty
      end
    end
  end

  describe "a new post in graetzl" do
    let(:post) { create(:post) }

    before { user.enable_website_notification Notifications::NewPost }

    context "when user is from the same graetzl" do
      let(:user) { create(:user, graetzl: post.graetzl) }

      it "user is notified" do
        expect(user.notifications.to_a).to be_empty
        post.create_activity :create, owner: create(:user)
        user.notifications.reload
        expect(user.notifications.to_a).to_not be_empty
      end
    end

    context "when user is NOT from the same graetzl" do
      let(:user) { create(:user, graetzl: create(:graetzl)) }

      it "user is NOT notified" do
        post.create_activity :create, owner: create(:user)
        expect(user.notifications.to_a).to be_empty
      end
    end
  end

  describe "new comment" do
    let(:commenter) { create(:user) }

    describe "on meeting" do
      before do
        user.enable_website_notification Notifications::CommentInUsersMeeting
        user.enable_website_notification Notifications::AlsoCommentedMeeting
        user.enable_website_notification Notifications::CommentInMeeting
      end

      let(:comment) { create(:comment,
                        commentable: meeting,
                        user: commenter) }

      context "when user is initiator" do
        before do
          create(:going_to,
                 user: user,
                 meeting: meeting,
                 role: GoingTo.roles[:initiator])
        end

        it "user is notified" do
          expect(user.notifications.to_a).to be_empty
          meeting.create_activity :comment, owner: commenter
          user.notifications.reload
          expect(user.notifications.to_a).to_not be_empty
        end

        it "notification has type 'CommentInUsersMeeting'" do
          meeting.create_activity :comment, owner: commenter
          user.notifications.reload
          types = user.notifications.pluck(:type)
          expect(types).to eq ['Notifications::CommentInUsersMeeting']
        end
      end

      context "when user is attendee" do
        before do
          create(:going_to,
                 user: user,
                 meeting: meeting,
                 role: GoingTo.roles[:attendee])
        end

        it "user is notified" do
          expect(user.notifications.to_a).to be_empty
          meeting.create_activity :comment, owner: commenter
          user.notifications.reload
          expect(user.notifications.to_a).to_not be_empty
        end

        it "notification has type 'CommentInMeeting'" do
          meeting.create_activity :comment, owner: commenter
          user.notifications.reload
          types = user.notifications.pluck(:type)
          expect(types).to eq ['Notifications::CommentInMeeting']
        end
      end

      context "when user commented before" do
        before { create(:comment, commentable: meeting, user: user) }

        it "user is notified" do
          expect(user.notifications.to_a).to be_empty
          meeting.create_activity :comment, owner: commenter
          user.notifications.reload
          expect(user.notifications.to_a).to_not be_empty
        end

        it "notification has type 'AlsoCommentedMeeting'" do
          meeting.create_activity :comment, owner: commenter
          user.notifications.reload
          types = user.notifications.pluck(:type)
          expect(types).to eq ['Notifications::AlsoCommentedMeeting']
        end
      end
    end

    describe "on post" do
      let(:post) { create(:post) }
      let(:comment) { create(:comment,
                        commentable: post,
                        user: commenter) }
      before do
        user.enable_website_notification Notifications::CommentOnUsersPost
        user.enable_website_notification Notifications::AlsoCommentedPost
      end

      context "when user post author" do
        before do
          post.author = user
          post.save
        end

        it "user is notified" do
          expect(user.notifications.to_a).to be_empty
          post.create_activity :comment, owner: commenter
          user.notifications.reload
          expect(user.notifications.to_a).to_not be_empty
        end

        it "notification has type 'Notifications::CommentOnUsersPost'" do
          post.create_activity :comment, owner: commenter
          user.notifications.reload
          types = user.notifications.pluck(:type)
          expect(types).to eq ['Notifications::CommentOnUsersPost']
        end
      end

      context "when user's location author" do
        let(:location) { create(:approved_location) }
        before do
          create(:location_ownership, location: location, user: user)
          post.author = location
          post.save
        end

        it "user is notified" do
          expect(user.notifications.to_a).to be_empty
          post.create_activity :comment, owner: commenter
          user.notifications.reload
          expect(user.notifications.to_a).to_not be_empty
        end

        it "notification has key 'Notifications::CommentOnLocationsPost'" do
          post.create_activity :comment, owner: commenter
          user.notifications.reload
          types = user.notifications.pluck(:type)
          expect(types).to eq ['Notifications::CommentOnLocationsPost']
        end
      end

      context "when user commented before" do
        before { create(:comment, commentable: post, user: user) }

        it "user is notified" do
          expect(user.notifications.to_a).to be_empty
          post.create_activity :comment, owner: commenter
          user.notifications.reload
          expect(user.notifications.to_a).to_not be_empty
        end

        it "notification has type 'Notifications::AlsoCommentedPost'" do
          post.create_activity :comment, owner: commenter
          user.notifications.reload
          types = user.notifications.pluck(:type)
          expect(types).to eq ['Notifications::AlsoCommentedPost']
        end
      end
    end

    describe "on user" do
      let(:comment) { create(:comment,
                        commentable: user,
                        user: commenter) }

      before { user.enable_website_notification Notifications::NewWallComment }

      it "wall user is notified" do
        expect(user.notifications.to_a).to be_empty
        user.create_activity :comment, owner: commenter, recipient: comment
        user.notifications.reload
        expect(user.notifications.to_a).to_not be_empty
      end

      it "notification has type 'Notifications::NewWallComment'" do
        user.create_activity :comment, owner: commenter, recipient: comment
        user.notifications.reload
        types = user.notifications.pluck(:type)
        expect(types).to eq ['Notifications::NewWallComment']
      end
    end
  end

  describe "new attendee" do
    let(:attendee) { create(:user) }
    let(:going_to) { create(:going_to,
                            meeting: meeting,
                            user: attendee,
                            role: GoingTo.roles[:attendee])
    }

    before { user.enable_website_notification Notifications::AttendeeInUsersMeeting }

    context "when user is initiator of meeting" do
      before do
        create(:going_to,
               user: user,
               meeting: meeting,
               role: GoingTo.roles[:initiator])
      end

      it "user is notified" do
        expect(user.notifications.to_a).to be_empty
        meeting.create_activity :go_to, owner: attendee
        user.notifications.reload
        expect(user.notifications.to_a).to_not be_empty
      end

      it "notification has type 'Notifications::AttendeeInUsersMeeting'" do
        meeting.create_activity :go_to, owner: attendee
        user.notifications.reload
        types = user.notifications.pluck(:type)
        expect(types).to eq ['Notifications::AttendeeInUsersMeeting']
      end
    end
  end

  describe "admin approves location" do
    let(:location) { create(:location) }

    before do
      user.enable_website_notification Notifications::LocationApproved
      create(:location_ownership, user: user, location: location)
    end

    it "user is notified" do
      expect(user.notifications.to_a).to be_empty
      location.create_activity :approve
      user.notifications.reload
      expect(user.notifications.to_a).to_not be_empty
    end

    it "notification has type 'Notifications::LocationApproved'" do
      location.create_activity :approve
      user.notifications.reload
      types = user.notifications.pluck(:type)
      expect(types).to eq ['Notifications::LocationApproved']
    end
  end

  describe "mail notifications" do
    before { user.enable_mail_notification(Notifications::NewMeeting, interval) }
    let(:user) { create(:user, graetzl: meeting.graetzl) }

    # context "when immediate notification is enabled" do
    #   let(:interval) { :immediate }
    #
    #   it "the notification is sent per mail immediatly" do
    #     spy = class_double("SendMailNotificationJob").as_stubbed_const
    #     #spy = class_double("SendMailNotificationJob")
    #     #allow(spy).to receive_messages(new: true, asyn: true, perform: true)
    #     #allow(spy).to receive_messages(:new, :async, :perform)
    #     allow_any_instance_of(spy).to receive(:perform)
    #     #allow(spy).to receive_message_chain(:new, :async, :perform)
    #     expect(user.mail_notifications(interval).to_a).to be_empty
    #     activity = meeting.create_activity :create, owner: create(:user)
    #     user.mail_notifications(interval).reload
    #     expect(user.mail_notifications(interval).to_a).not_to be_empty
    #     expect(spy).to have_received(:perform).with(user.id, "immediate", user.notifications.last.id)
    #   end
    # end

    context "when daily notification is enabled" do
      let(:interval) { :daily }

      it "the notification is sent at the end of day" do
        expect(user.mail_notifications(interval).to_a).to be_empty
        meeting.create_activity :create, owner: create(:user)
        user.mail_notifications(interval).reload
        expect(user.mail_notifications(interval).to_a).not_to be_empty
      end
    end

    context "when weekly notification is enabled" do
      let(:interval) { :weekly }

      it "the notification is sent at the end of day" do
        expect(user.mail_notifications(interval).to_a).to be_empty
        meeting.create_activity :create, owner: create(:user)
        user.mail_notifications(interval).reload
        expect(user.mail_notifications(interval).to_a).not_to be_empty
      end
    end
  end

  describe "a website notification type is enabled after notification creation" do
    let(:user) { create(:user, graetzl: meeting.graetzl) }

    it "does not create a notification record" do
      expect(user.enabled_website_notification?(Notifications::NewMeeting)).to be_falsy
      expect(user.website_notifications.to_a).to be_empty
      meeting.create_activity :create, owner: create(:user)
      expect(user.website_notifications.to_a).to be_empty
      user.enable_website_notification(Notifications::NewMeeting)
      user.notifications.reload
      expect(user.website_notifications.to_a).to be_empty
    end
  end

  describe '.dasherized' do
    let(:notification_subclass) { Notifications::NewMeeting }

    it 'returns dasherized subclass name' do
      expect(notification_subclass.dasherized).to eq 'new-meeting'
    end
  end

  describe "#to_partial_path" do
    let(:notification) { build(:notification, type: "Notifications::SomethingNew") }

    it "returns partial path for notification type" do
      expect(notification.to_partial_path).to include('notification', 'something_new')
    end
  end

  describe '#mail_template' do
    let(:notification) { build(:notification, type: "Notification::SomethingNew") }

    it 'returns mandrill template slug' do
      expect(notification.mail_template).to eq 'notification-something-new'
    end
  end
end
