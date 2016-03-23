require 'rails_helper'

RSpec.describe Notifications::AlsoCommentedUserPost, type: :model do

  describe '.triggered_by?(activity)' do
    let(:activity) { build_stubbed(:activity, key: 'user_post.comment') }
    let(:other_activity) { build_stubbed(:activity, key: 'user_post.create') }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::AlsoCommentedUserPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::AlsoCommentedUserPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:post) { create :user_post }
    let!(:users) { create_list :user, 5 }
    let!(:owner) { create :user }
    let!(:activity) { create :activity, trackable: post, owner: owner }

    before do
      users.each{|user| create(:comment, user: user, commentable: post) }
      create(:comment, user: owner, commentable: post)
    end

    subject(:receivers) { Notifications::AlsoCommentedUserPost.receivers(activity) }

    it 'returns all previous commenters' do
      expect(receivers).to match_array users
    end

    it 'excludes owner of activity' do
      expect(receivers).not_to include owner
    end
  end

  describe '.condition(activity)' do
    let(:activity) { build(:activity) }

    subject(:condition) { Notifications::AlsoCommentedUserPost.condition activity }

    it 'returns always true' do
      expect(condition).to eq true
    end
  end
end
