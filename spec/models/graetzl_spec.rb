require 'rails_helper'

RSpec.describe Graetzl, type: :model do

  it 'has a valid factory' do
    expect(build(:graetzl)).to be_valid
  end

  describe 'associations' do
    let(:graetzl) { create(:graetzl) }

    it 'has curator' do
      expect(graetzl).to respond_to(:curator)
    end

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

  describe 'macros' do
    let(:graetzl) { create(:graetzl) }

    it 'has friendly_id' do
      expect(graetzl).to respond_to(:slug)
    end

    it 'has state (default :open)' do
      expect(graetzl).to respond_to(:state)
      expect(graetzl.open?).to be_truthy
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

  describe '#activity', job: true do
    let(:graetzl) { create(:graetzl) }

    context 'when no activity in graetzl' do
      it 'returns empty array' do
        expect(graetzl.activity).to be_empty
        expect(graetzl.activity).to be_kind_of(Array)
      end
    end

    context 'when activity on trackables in graetzl' do
      let!(:meeting) { create(:meeting, graetzl: graetzl) }
      let!(:post) { create(:post, graetzl: graetzl) }

      it 'includes most recent activity per trackable, most recent first' do
        PublicActivity.with_tracking do
          create_post = post.create_activity :create
          comment_on_post = post.create_activity :comment
          create_meeting = meeting.create_activity :create
          comment_on_meeting = meeting.create_activity :comment
          create_other_meeting = create(:meeting, graetzl: graetzl).create_activity :create

          expect(graetzl.activity).to eq [create_other_meeting, comment_on_meeting, comment_on_post]
          expect(graetzl.activity).not_to include(create_post)
        end
      end

      it 'includes meeting:create activity' do
        PublicActivity.with_tracking do
          activity = meeting.create_activity :create
          expect(graetzl.activity).to include(activity)
        end
      end

      it 'includes meeting:comment activity' do
        PublicActivity.with_tracking do
          activity = meeting.create_activity :comment
          expect(graetzl.activity).to include(activity)
        end
      end

      it 'includes meeting:go_to activity' do
        PublicActivity.with_tracking do
          activity = meeting.create_activity :go_to
          expect(graetzl.activity).to include(activity)
        end
      end

      it 'does not have meeting:update activity' do
        PublicActivity.with_tracking do
          activity = meeting.create_activity :update
          expect(graetzl.activity).not_to include(activity)
        end
      end

      it 'includes post:create activity' do
        PublicActivity.with_tracking do
          activity = post.create_activity :create
          expect(graetzl.activity).to include(activity)
        end
      end

      it 'includes post:comment activity' do
        PublicActivity.with_tracking do
          activity = post.create_activity :comment
          expect(graetzl.activity).to include(activity)
        end
      end
    end

    context 'with activity on artifacts outside graetzl' do
      let(:other_graetzl) { create(:graetzl) }
      let!(:meeting) { create(:meeting, graetzl: other_graetzl) }

      context 'when owner not from graetzl' do
        it 'does not have activity' do
          PublicActivity.with_tracking do
            activity = meeting.create_activity :comment, owner: create(:user, graetzl: other_graetzl)
            expect(graetzl.activity).not_to include(activity)
          end
        end
      end

      context 'when activity owner from graetzl' do
        let(:user) { create(:user, graetzl: graetzl) }

        it 'has activity in both graetzls' do
          PublicActivity.with_tracking do
            activity = meeting.create_activity :comment, owner: user
            expect(graetzl.activity).to include(activity)
            expect(other_graetzl.activity).to include(activity)
          end
        end
      end
    end
  end
end
