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

    it 'has comments' do
      expect(user).to respond_to(:comments)
    end

    it 'has avatar' do
      expect(user).to respond_to(:avatar)
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

  describe '#autosave_associated_records_for_graetzl' do
    context 'when graetzl in db' do
      let!(:g_exiting) { create(:graetzl) }

      it 'associates existing graetzl' do
        user = create(:user, graetzl: build(:graetzl, name: g_exiting.name))
        expect(user.graetzl).to eq(g_exiting)
      end

      it 'does not create new graetzl' do
        expect {
          user = create(:user, graetzl: build(:graetzl, name: g_exiting.name))
        }.not_to change(Graetzl, :count)
      end
    end

    context 'when graetzl not in db' do
      let!(:g_default) { create(:graetzl) }

      it 'associates with first graetzl record' do
        user = create(:user, graetzl: build(:graetzl))
        expect(user.graetzl).to eq(g_default)
      end

      it 'does not create new graetzl record' do
        expect {
          user = create(:user, graetzl: build(:graetzl))
        }.not_to change(Graetzl, :count)
      end
    end
  end

  describe '#go_to' do
    let(:user) { create(:user) }
    let(:meeting) { create(:meeting) }

    context 'when attendee' do
      it 'creates new going_to with default role' do
        expect {
          user.go_to(meeting)
        }.to change(GoingTo, :count).by(1)
      expect(user.going_tos.last.role).to eq(GoingTo::ROLES[:attendee])
      end

      it 'adds going_to to user' do
        expect {
          user.go_to(meeting)
        }.to change(user.going_tos, :count).by(1)
      end

      it 'add meeting to user' do
        user.go_to(meeting)
        expect(user.meetings.last).to eq(meeting)
      end
    end

    context 'when initator' do      
      it 'creates going_to with role initator' do
        expect {
        user.go_to(meeting, GoingTo::ROLES[:initator])
      }.to change(GoingTo, :count).by(1)
      expect(user.going_tos.last.role).to eq(GoingTo::ROLES[:initator])
      end
    end
  end

  describe '#initiated?(meeting)' do
    let(:user) { create(:user) }
    let(:meeting) { create(:meeting) }

    context 'when initiator' do
      before do
        create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:initiator])
      end

      it 'returns true' do
        expect(user.initiated?(meeting)).to be_truthy
      end
    end

    context 'when attendee' do
      before do
        create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:attendee])
      end

      it 'returns false' do
        expect(user.initiated?(meeting)).to be_falsey
      end
    end

    context 'when not going' do
      it 'returns false' do
        expect(user.initiated?(meeting)).to be_falsey
      end
    end
  end

  describe '#going_to?(meeting)' do
    let(:user) { create(:user) }
    let(:meeting) { create(:meeting) }

    context 'when initiator' do
      before do
        create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:initiator])
      end

      it 'returns true' do
        expect(user.going_to?(meeting)).to be_truthy
      end
    end

    context 'when attendee' do
      before do
        create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:attendee])
      end

      it 'returns true' do
        expect(user.going_to?(meeting)).to be_truthy
      end
    end

    context 'when not going' do
      it 'returns false' do
        expect(user.going_to?(meeting)).to be_falsey
      end
    end
  end

  describe "website_notifications" do
    let(:graetzl) { create(:graetzl) }
    let(:user) { create(:user, :graetzl => graetzl) }
    let(:meeting) { create(:meeting, :graetzl => graetzl) }
    let(:post) { create(:post, :graetzl => graetzl) }

    it "can be enabled for a specific type" do
      PublicActivity.with_tracking do
        type = :new_meeting_in_graetzl
        expect(user.enabled_website_notification?(type)).to be_falsey  
        user.enable_website_notification(type)
        expect(user.enabled_website_notification?(type)).to be_truthy
      end
    end

    it "can be toggled for a specific type" do
      PublicActivity.with_tracking do
        type = :new_meeting_in_graetzl
        expect(user.enabled_website_notification?(type)).to be_falsey  
        user.toggle_website_notification(type)
        expect(user.enabled_website_notification?(type)).to be_truthy
        user.toggle_website_notification(type)
        expect(user.enabled_website_notification?(type)).to be_falsey  
      end
    end

    describe "meeting activities" do
      context "of meetings that the user organizes" do
        let(:attendee) { create(:user, :graetzl => graetzl) }
        let!(:going_to) do
          create(:going_to,
                            :meeting => meeting,
                            :user => attendee,
                            :role => GoingTo::ROLES[:attendee])
        end

        before do
          create(:going_to,
                 :user => user,
                 :meeting => meeting,
                 :role => GoingTo::ROLES[:initiator])
        end

        it "a new participant activity notifies the user" do
          PublicActivity.with_tracking do
            a = going_to.create_activity :create, :owner => attendee 
            expect(user.website_notifications.to_a).not_to include(a)
            user.enable_website_notification(:another_attendee)
            expect(user.website_notifications.to_a).to include(a)
          end
        end

        it "a new comment notifies the user" do
          PublicActivity.with_tracking do
            comment = create(:comment, :user => attendee, :commentable => meeting)
            a = comment.create_activity :create, :owner => attendee 
            expect(user.website_notifications.to_a).not_to include(a)
            user.enable_website_notification(:user_comments_users_meeting)
            expect(user.website_notifications.to_a).to include(a)
          end
        end
      end

      context "user is going to" do
        before { create(:going_to, :user => user, :meeting => meeting) }

        it "an update notifies the user" do
          PublicActivity.with_tracking do
            a = meeting.create_activity :update, :owner => create(:user) 
            expect(user.website_notifications.to_a).not_to include(a)
            user.enable_website_notification(:update_of_meeting)
            expect(user.website_notifications).to include(a)
          end
        end

        it "an organizer comment notifies the user" do
          PublicActivity.with_tracking do
            organizer = create(:user)
            create(:going_to, :meeting => meeting,
                   :user => organizer,
                   :role => GoingTo::ROLES[:initiator])

            comment = create(:comment, :user => organizer, :commentable => meeting)
            a = comment.create_activity :create, :owner => organizer 
            expect(user.website_notifications.to_a).not_to include(a)
            user.enable_website_notification(:organizer_comments)
            expect(user.website_notifications.to_a).to include(a)
          end
        end

        it "a user comment notifies the user" do
          PublicActivity.with_tracking do
            comment = create(:comment, :user => create(:user), :commentable => meeting)
            a = comment.create_activity :create, :owner => comment.user 
            expect(user.website_notifications.to_a).not_to include(a)
            user.enable_website_notification(:another_user_comments)
            expect(user.website_notifications.to_a).to include(a)
          end
        end
      end

      context "user is not going to" do
        it "an update does not notify the user" do
          PublicActivity.with_tracking do
            a = meeting.create_activity :update, :owner => create(:user) 
            expect(user.website_notifications.to_a).not_to include(a)
            user.enable_website_notification(:update_of_meeting)
            expect(user.website_notifications.to_a).not_to include(a)
          end
        end

        it "an organizer comment does not notify the user" do
          PublicActivity.with_tracking do
            organizer = create(:user)
            create(:going_to, :meeting => meeting,
                   :user => organizer,
                   :role => GoingTo::ROLES[:initiator])

            comment = create(:comment, :user => organizer, :commentable => meeting)
            a = comment.create_activity :create, :owner => organizer 
            expect(user.website_notifications.to_a).not_to include(a)
            user.enable_website_notification(:organizer_comments)
            expect(user.website_notifications.to_a).not_to include(a)
          end
        end

        it "a user comment does not notify the user" do
          PublicActivity.with_tracking do
            comment = create(:comment, :user => create(:user), :commentable => meeting)
            a = comment.create_activity :create, :owner => comment.user 
            expect(user.website_notifications.to_a).not_to include(a)
            user.enable_website_notification(:another_user_comments)
            expect(user.website_notifications.to_a).not_to include(a)
          end
        end
      end
    end

    context "activities within the user's graetzl" do
      it "returns new meeting activities" do
        PublicActivity.with_tracking do
          type = :new_meeting_in_graetzl
          a = meeting.create_activity :create, owner: create(:user)
          expect(user.website_notifications.to_a).not_to include(a)
          user.enable_website_notification(type)
          expect(user.website_notifications.to_a).to include(a)
        end
      end

      it "returns new post activities" do
        PublicActivity.with_tracking do
          type = :new_post_in_graetzl
          a = post.create_activity :create, owner: create(:user)
          expect(user.website_notifications.to_a).not_to include(a)
          user.enable_website_notification(type)
          expect(user.website_notifications.to_a).to include(a)
        end
      end

      context "when the user creates activity" do
        it "does not return the activity" do
          PublicActivity.with_tracking do
            a = post.create_activity :create, owner: user
            b = meeting.create_activity :create, owner: user

            user.enable_website_notification(:new_meeting_in_graetzl)
            user.enable_website_notification(:new_post_in_graetzl)
            expect(user.website_notifications.to_a).not_to include(a)
            expect(user.website_notifications.to_a).not_to include(b)
          end
        end
      end

      describe "all types enabled" do
        it "returns all activities" do
          PublicActivity.with_tracking do
            a = meeting.create_activity :create, owner: create(:user)
            b = post.create_activity :create, owner: create(:user)
            expect(user.website_notifications.to_a).not_to include(a)
            expect(user.website_notifications.to_a).not_to include(b)
            user.enable_website_notification(:new_post_in_graetzl)
            user.enable_website_notification(:new_meeting_in_graetzl)
            expect(user.website_notifications.to_a).to include(a)
            expect(user.website_notifications.to_a).to include(b)
          end
        end
      end
    end

    context "activities outside the user's graetzl" do
      let(:meeting) { create(:meeting, :graetzl => create(:graetzl)) }
      let(:post) { create(:post, :graetzl => create(:graetzl)) }

      it "does not return new meeting activities" do
        PublicActivity.with_tracking do
          type = :new_meeting_in_graetzl
          a = meeting.create_activity :create, owner: create(:user)
          user.enable_website_notification(type)
          expect(user.website_notifications.to_a).not_to include(a)
        end
      end

      it "does not return new post activities" do
        PublicActivity.with_tracking do
          type = :new_post_in_graetzl
          a = post.create_activity :create, owner: create(:user)
          user.enable_website_notification(type)
          expect(user.website_notifications.to_a).not_to include(a)
        end
      end

      describe "all types enabled" do
        it "returns none" do
          PublicActivity.with_tracking do
            a = meeting.create_activity :create, owner: create(:user)
            b = post.create_activity :create, owner: create(:user)
            expect(user.website_notifications.to_a).not_to include(a)
            expect(user.website_notifications.to_a).not_to include(b)
            user.enable_website_notification(:new_meeting_in_graetzl)
            user.enable_website_notification(:new_post_in_graetzl)
            expect(user.website_notifications.to_a).not_to include(a)
            expect(user.website_notifications.to_a).not_to include(b)
          end
        end
      end
    end

    context "when all notifications are enabled" do
      let(:other_user) { create(:user) }

      before do
        User::WEBSITE_NOTIFICATION_TYPES.keys.each do |k|
          user.enable_website_notification(k)
        end
      end

      it "returns all related activities" do
        PublicActivity.with_tracking do
          activities = [ ]
          activities << meeting.create_activity(:create, :owner => other_user)
          activities << post.create_activity(:create, :owner => other_user)

          create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:attendee])
          create(:going_to, user: other_user, meeting: meeting, role: GoingTo::ROLES[:initiator])
          activities << meeting.create_activity(:update, :owner => other_user)
          comment_by_organizer = create(:comment, user: other_user, commentable: meeting)
          activities << comment_by_organizer.create_activity(:create, :owner => other_user)
          comment_by_user = create(:comment, user: create(:user), commentable: meeting)
          activities << comment_by_user.create_activity(:create, owner: create(:user))

          organized_meeting = create(:meeting, :graetzl => graetzl)
          create(:going_to, user: user, meeting: organized_meeting, role: GoingTo::ROLES[:initiator])
          going_to = create(:going_to, user: other_user, meeting: organized_meeting, role: GoingTo::ROLES[:attendee])
          activities << going_to.create_activity(:create, :owner => other_user)
          comment = create(:comment, user: other_user, commentable: organized_meeting)
          activities << comment.create_activity(:create, owner: other_user)

          result = user.website_notifications.to_a.collect(&:id)
          activities.each do |a|
            expect(result).to include(a.id)
          end          
        end
      end
    end
  end
end
