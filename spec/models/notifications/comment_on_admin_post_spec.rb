require 'rails_helper'

RSpec.describe Notifications::CommentOnAdminPost, type: :model do
  describe '.triggered_by?(activity)' do
    let(:activity) { build :activity, key: 'admin_post.comment' }
    let(:other_activity) { build :activity, key: 'admin_post.create' }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::CommentOnAdminPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::CommentOnAdminPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let(:user) { create :user }
    let(:admin_post) { create :admin_post, author: user }
    let(:activity) { create :activity, trackable: admin_post }

    subject(:receivers) { Notifications::CommentOnAdminPost.receivers(activity) }

    it 'returns post author' do
      expect(receivers).to eq [user]
    end
  end

  describe '.condition(activity)' do
    let(:user) { create :user }
    let(:admin_post) { create :admin_post, author: user }
    let(:activity) { create :activity, trackable: admin_post }

    subject(:condition) { Notifications::CommentOnAdminPost.condition activity }

    it 'returns false if author activity owner' do
      allow(activity).to receive(:owner_id) { user.id }
      expect(condition).to eq false
    end

    it 'returns true if author not activity owner' do
      expect(condition).to eq true
    end
  end
end
