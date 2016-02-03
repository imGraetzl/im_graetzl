require 'rails_helper'

RSpec.describe Notifications::CommentOnLocationsPost, type: :model do

  describe '.triggered_by?(activity)' do
    let(:activity) { build_stubbed(:activity, key: 'post.comment') }
    let(:other_activity) { build_stubbed(:activity, key: 'post.create') }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::CommentOnLocationsPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::CommentOnLocationsPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:location) { create(:approved_location) }
    let(:users) { create_list(:user, 3) }
    let!(:post) { create(:post, author: location) }
    let!(:activity) { create(:activity, trackable: post) }

    before do
      users.each{|user| create(:location_ownership, user: user, location: location)}
    end

    subject(:receivers) { Notifications::CommentOnLocationsPost.receivers(activity) }

    it 'returns location users' do
      expect(receivers.to_a).to match_array users
    end
  end

  describe '.condition(activity)' do
    let!(:location) { create :approved_location }
    let!(:post) { create(:post, author: location) }
    let!(:user) { create :user }
    let!(:activity) { create(:activity, trackable: post, owner: user) }

    subject(:condition) { Notifications::CommentOnLocationsPost.condition activity }

    it 'returns false if author != Location' do
      allow(post).to receive(:author_type) { 'User' }
      expect(condition).to eq false
    end

    it 'returns false if author not present' do
      post.author = nil
      post.save(validate: false)
      expect(condition).to eq false
    end

    it 'returns false if location owner activity owner' do
      create(:location_ownership, user: user, location: location)
      expect(condition).to eq false
    end

    it 'returns true if author not activity owner' do
      expect(condition).to eq true
    end
  end
end
