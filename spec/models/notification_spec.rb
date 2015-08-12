require 'rails_helper'

RSpec.describe Notification, type: :model do
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
    before { user.enable_website_notification :new_meeting_in_graetzl }
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
    before { user.enable_website_notification :update_of_meeting }

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

  describe "a new post in graetzl" do
    let(:post) { create(:post) }

    before { user.enable_website_notification :new_post_in_graetzl }

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

    before do
      user.enable_website_notification :user_comments_users_meeting
      user.enable_website_notification :another_user_comments
      user.enable_website_notification :initiator_comments
    end

    describe "on meeting" do
      let(:comment) { create(:comment,
                        commentable: meeting,
                        user: commenter) }


      context "when commenter is initiator" do
        before do
          create(:going_to,
                 meeting: meeting,
                 user: commenter,
                 role: GoingTo.roles[:initiator])
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
      end

      context "when user is initiator" do
        before do
          create(:going_to,
                 meeting: meeting,
                 user: commenter,
                 role: GoingTo.roles[:attendee])
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
      end

      context "when user is another attendee" do
        before do
          create(:going_to,
                 meeting: meeting,
                 user: commenter,
                 role: GoingTo.roles[:attendee])
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

    before do
      user.enable_website_notification :another_attendee
    end

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
    end
  end

  describe "attendee left meeting" do
    before do
      user.enable_website_notification :attendee_left
    end

    let(:attendee) { create(:user) }
    let(:going_to) { create(:going_to,
                            meeting: meeting,
                            user: attendee,
                            role: GoingTo.roles[:attendee])
    }

    context "when user is initiator of meeting" do
      before do
        create(:going_to,
               user: user,
               meeting: meeting,
               role: GoingTo.roles[:initiator])
      end

      it "user is notified" do
        expect(user.notifications.to_a).to be_empty
        meeting.create_activity :left, owner: attendee
        user.notifications.reload
        expect(user.notifications.to_a).to_not be_empty
      end
    end
  end

  describe "mail notifications" do
    before { user.enable_mail_notification(:new_meeting_in_graetzl, interval) }
    let(:user) { create(:user, graetzl: meeting.graetzl) }

    context "when immediate notification is enabled" do
      let(:interval) { :immediate }

      it "the notification is sent per mail immediatly" do
        spy = class_double("SendMailNotificationJob", perform_later: nil).as_stubbed_const
        expect(user.mail_notifications(interval).to_a).to be_empty
        activity = meeting.create_activity :create, owner: create(:user)
        user.mail_notifications(interval).reload
        expect(user.mail_notifications(interval).to_a).not_to be_empty
        expect(spy).to have_received(:perform_later).with(user.id,
                                                          activity.id,
                                                          "new_meeting_in_graetzl")
      end
    end

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
end
