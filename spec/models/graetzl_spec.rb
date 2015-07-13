require 'rails_helper'

RSpec.describe Graetzl, type: :model do

  it 'has a valid factory' do
    expect(build(:graetzl)).to be_valid
  end

  describe 'associations' do
    let(:graetzl) { create(:graetzl) }

    it 'has users' do
      expect(graetzl).to respond_to(:users)
    end

    it 'has meetings' do
      expect(graetzl).to respond_to(:meetings)      
    end

    it 'has posts' do
      expect(graetzl).to respond_to(:posts)      
    end

    it 'has locations' do
      expect(graetzl).to respond_to(:locations)      
    end

    describe 'destroy associated records' do
      describe 'meetings' do
        before { 3.times { create(:meeting, graetzl: graetzl) } }

        it 'has meetings' do
          expect(graetzl.meetings.count).to eq(3)
        end

        it 'destroys meetings' do
          meetings = graetzl.meetings
          graetzl.destroy
          meetings.each do |meeting|
            expect(Meeting.find_by_id(meeting.id)).to be_nil
          end
        end
      end

      describe 'posts' do
        before { 3.times { create(:post, graetzl: graetzl) } }

        it 'has posts' do
          expect(graetzl.posts.count).to eq(3)
        end

        it 'destroys posts' do
          posts = graetzl.posts
          graetzl.destroy
          posts.each do |post|
            expect(Post.find_by_id(post.id)).to be_nil
          end
        end
      end

      describe 'locations' do
        before { 3.times { create(:location, graetzl: graetzl) } }

        it 'has locations' do
          expect(graetzl.locations.count).to eq(3)
        end

        it 'destroys locations' do
          locations = graetzl.locations
          graetzl.destroy
          locations.each do |location|
            expect(Location.find_by_id(location.id)).to be_nil
          end
        end
      end
    end
  end

  describe '#districts' do
    let(:graetzl) { create(:graetzl,
      area: 'POLYGON ((1.0 1.0, 1.0 5.0, 5.0 5.0, 5.0 1.0, 1.0 1.0))') }
    let!(:d_intersect) { create(:district,
      area: 'POLYGON ((3.0 3.0, 3.0 6.0, 6.0 6.0, 3.0 3.0))') }
    let!(:d_covers) { create(:district,
      area: 'POLYGON ((0.0 0.0, 0.0 6.0, 6.0 6.0, 6.0 0.0, 0.0 0.0))') }
    let!(:d_outside) { create(:district,
      area: 'POLYGON ((6.0 6.0, 10.0 6.0, 10.0 10.0, 6.0 6.0))') }

    subject(:districts) { graetzl.districts }

    it 'returns intersecting districts' do
      expect(districts.size).to eq 2
    end

    it 'includes intersecting' do
      expect(districts).to include d_intersect
    end

    it 'includes covering' do
      expect(districts).to include d_covers
    end

    it 'excludes outside' do
      expect(districts).not_to include d_outside
    end
  end

  describe '#activity' do
    let(:graetzl) { create(:graetzl) }
    let(:random_user) { create(:user) }

    it 'is empty when no activity' do
      expect(graetzl.activity).to be_empty
    end

    context 'with activity on artifacts in graetzl' do
      let(:meeting) { create(:meeting, graetzl: graetzl) }
      let(:post) { create(:post, graetzl: graetzl) }

      it 'has activities oldest first' do
        PublicActivity.with_tracking do
          old_activity = post.create_activity :create
          new_activity = meeting.create_activity :create
          latest_activity = create(:meeting, graetzl: graetzl).create_activity :create

          expect(graetzl.activity).to contain_exactly(old_activity, new_activity, latest_activity)
        end
      end

      it 'has meeting:create activity' do
        PublicActivity.with_tracking do
          activity = meeting.create_activity :create, owner: meeting.initiator

          expect(graetzl.activity).to include(activity)
        end
      end

      it 'has meeting:comment activity' do
        PublicActivity.with_tracking do
          activity = meeting.create_activity :comment, owner: random_user

          expect(graetzl.activity).to include(activity)
        end
      end

      it 'has meeting:go_to activity' do
        PublicActivity.with_tracking do
          activity = meeting.create_activity :go_to, owner: random_user

          expect(graetzl.activity).to include(activity)
        end
      end

      it 'does not have meeting:update activity' do
        PublicActivity.with_tracking do
          activity = meeting.create_activity :update, owner: random_user

          expect(graetzl.activity).not_to include(activity)
        end
      end

      it 'has only latest activity on meeting' do
        PublicActivity.with_tracking do
          create_activity = meeting.create_activity :create, owner: meeting.initiator
          comment_activity = meeting.create_activity :comment, owner: random_user
          last_activity = meeting.create_activity :go_to, owner: random_user
          
          expect(graetzl.activity).to include(last_activity)
          expect(graetzl.activity).not_to include(create_activity, comment_activity)
        end
      end

      it 'has post:create activity' do
        PublicActivity.with_tracking do
          activity = post.create_activity :create, owner: random_user

          expect(graetzl.activity).to include(activity)
        end
      end

      it 'has post:comment activity' do
        PublicActivity.with_tracking do
          activity = post.create_activity :comment, owner: random_user

          expect(graetzl.activity).to include(activity)
        end
      end

      it 'has only latest activity on post' do
        PublicActivity.with_tracking do
          create_activity = post.create_activity :create, owner: post.user
          comment_activity = post.create_activity :comment, owner: random_user
          last_activity = post.create_activity :comment, owner: random_user
          
          expect(graetzl.activity).to include(last_activity)
          expect(graetzl.activity).not_to include(create_activity, comment_activity)
        end
      end

      it 'has post and meeting activity' do
        PublicActivity.with_tracking do
          old_activity_1 = post.create_activity :create, owner: post.user
          old_activity_2 = post.create_activity :comment, owner: random_user
          post_activity = post.create_activity :comment, owner: random_user
          old_activity_3 = meeting.create_activity :create, owner: random_user
          meeting_activity = meeting.create_activity :comment, owner: random_user
          
          expect(graetzl.activity).to include(meeting_activity, post_activity)
          expect(graetzl.activity).not_to include(old_activity_1, old_activity_2, old_activity_3)
        end
      end
    end

    context 'with activity on artifacts outside graetzl' do
      let(:other_graetzl) { create(:graetzl) }
      let(:meeting) { create(:meeting, graetzl: other_graetzl) }

      context 'when owner not from graetzl' do
        it 'does not have activity' do
          PublicActivity.with_tracking do
            activity = meeting.create_activity :comment, owner: random_user

            expect(graetzl.activity).not_to include(activity)
          end
        end
      end

      context 'when activity owner from graetzl' do
        let(:user_from_graetzl) { create(:user, graetzl: graetzl) }

        it 'has activity in both graetzls' do
          PublicActivity.with_tracking do
            activity = meeting.create_activity :comment, owner: user_from_graetzl
            
            expect(graetzl.activity).to include(activity)
            expect(other_graetzl.activity).to include(activity)
          end
        end
      end
    end
  end
end
