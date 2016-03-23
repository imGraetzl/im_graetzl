require 'rails_helper'

RSpec.describe Notifications::CommentOnLocationPost, type: :model do

  describe '.triggered_by?(activity)' do
    let(:activity) { build :activity, key: 'location_post.comment' }
    let(:other_activity) { build :activity, key: 'post.create' }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::CommentOnLocationPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::CommentOnLocationPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:location) { create :location, :approved }
    let(:users) { create_list :user, 3 }
    let!(:location_post) { create :location_post, author: location }
    let!(:activity) { create :activity, trackable: location_post }

    before do
      users.each{|user| create(:location_ownership, user: user, location: location)}
    end

    subject(:receivers) { Notifications::CommentOnLocationPost.receivers(activity) }

    it 'returns location users' do
      expect(receivers).to match_array users
    end
  end

  describe '.condition(activity)' do
    let!(:location) { create :location, :approved }
    let!(:location_post) { create :location_post, author: location }
    let!(:user) { create :user }
    let!(:activity) { create :activity, trackable: location_post, owner: user }

    subject(:condition) { Notifications::CommentOnLocationPost.condition activity }

    it 'returns false if author != Location' do
      allow(location_post).to receive(:author_type) { 'User' }
      expect(condition).to eq false
    end

    it 'returns false if author not present' do
      location_post.author = nil
      location_post.save(validate: false)
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
