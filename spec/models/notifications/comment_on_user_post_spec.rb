require 'rails_helper'

RSpec.describe Notifications::CommentOnUserPost, type: :model do
  describe '.triggered_by?(activity)' do
    let(:activity) { build :activity, key: 'user_post.comment' }
    let(:other_activity) { build :activity, key: 'user_post.create' }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::CommentOnUserPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::CommentOnUserPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:user) { create :user }
    let!(:user_post) { create :user_post, author: user }
    let!(:activity) { create :activity, trackable: user_post }

    subject(:receivers) { Notifications::CommentOnUserPost.receivers(activity) }

    it 'returns post author' do
      expect(receivers).to eq [user]
    end
  end

  describe '.condition(activity)' do
    let!(:user) { create :user }
    let!(:user_post) { create :user_post, author: user }
    let!(:activity) { create :activity, trackable: user_post }

    subject(:condition) { Notifications::CommentOnUserPost.condition activity }

    it 'returns false if author != User' do
      allow(user_post).to receive(:author_type) { 'Location' }
      expect(condition).to eq false
    end

    it 'returns false if author not present' do
      user_post.author = nil
      user_post.save(validate: false)
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
