require 'rails_helper'

RSpec.describe Notifications::CommentOnUsersPost, type: :model do

  describe '.triggered_by?(activity)' do
    let(:activity) { build_stubbed(:activity, key: 'post.comment') }
    let(:other_activity) { build_stubbed(:activity, key: 'post.create') }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::CommentOnUsersPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::CommentOnUsersPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:user) { create(:user) }
    let!(:post) { create(:post, author: user) }
    let!(:activity) { create(:activity, trackable: post) }

    subject(:receivers) { Notifications::CommentOnUsersPost.receivers(activity) }

    it 'returns post author' do
      expect(receivers).to eq [user]
    end
  end

  describe '.condition(activity)' do
    let!(:user) { create(:user) }
    let!(:post) { create(:post, author: user) }
    let!(:activity) { create(:activity, trackable: post) }

    subject(:condition) { Notifications::CommentOnUsersPost.condition activity }

    it 'returns false if author != User' do
      allow(post).to receive(:author_type) { 'Location' }
      expect(condition).to eq false
    end

    it 'returns false if author not present' do
      post.author = nil
      post.save(validate: false)
      expect(condition).to eq false
    end

    it 'returns false if author activity owner' do
      allow(activity).to receive(:owner_id) { user.id }
      expect(condition).to eq false
    end

    it 'returns true if author not activity owner' do
      expect(condition).to eq true
    end
  end
end
