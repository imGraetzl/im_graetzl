require 'rails_helper'

RSpec.describe User, type: :model do

  it 'has a valid factory for normal users' do
    expect(build_stubbed(:user)).to be_valid
  end

  it 'has a valid factory for admins' do
    expect(build_stubbed(:admin)).to be_valid
    expect(build_stubbed(:admin).admin?).to be_truthy
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
        expect(Activity.count).to eq 3
        expect(Notification.count).to eq 9

        user.destroy

        expect(Notification.count).to eq 0
        expect(Activity.count).to eq 0
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

    it 'has curator' do
      expect(user).to respond_to(:curator)
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

      describe 'curator' do
        before { create(:curator, user: user) }

        it 'has curator' do
          expect(user.curator).to be
        end

        it 'destroys curator' do
          expect{
            user.destroy
          }.to change(Curator, :count).by(-1)
        end
      end
    end
  end
end
