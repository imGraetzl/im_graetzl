require 'rails_helper'

RSpec.describe Notifications::NewWallComment, type: :model do

  describe '.triggered_by?(activity)' do
    let(:activity) { build_stubbed(:activity, key: 'user.comment') }
    let(:other_activity) { build_stubbed(:activity, key: 'user.create') }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::NewWallComment.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::NewWallComment.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:user) { create :user }
    let!(:commenter) { create :user }
    let!(:comment) { create(:comment, user: commenter, commentable: user) }
    let!(:activity) { create(:activity, trackable: user, owner: commenter, recipient: comment) }

    subject(:receivers) { Notifications::NewWallComment.receivers(activity) }

    it 'returns all wall user' do
      expect(receivers.to_a).to match_array [user]
    end
  end

  describe '.condition(activity)' do
    let(:activity) { build_stubbed(:activity, owner: create(:user), recipient: create(:user)) }

    subject(:condition) { Notifications::NewWallComment.condition activity }

    it 'returns true if owner and recipient present' do
      expect(condition).to eq true
    end

    it 'returns false if owner or recipient not present' do
      allow(activity).to receive(:owner) { nil }
      allow(activity).to receive(:recipient) { nil }
      expect(condition).to eq false
    end
  end
end
