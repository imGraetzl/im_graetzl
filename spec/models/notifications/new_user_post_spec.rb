require 'rails_helper'

RSpec.describe Notifications::NewUserPost, type: :model do

  describe '.triggered_by?(activity)' do
    let(:activity) { build_stubbed(:activity, key: 'post.create') }
    let(:other_activity) { build_stubbed(:activity, key: 'post.comment') }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::NewUserPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::NewUserPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:graetzl) { create(:graetzl) }
    let!(:users) { create_list(:user, 10, graetzl: graetzl) }
    let!(:post) { create(:post, graetzl: graetzl) }
    let!(:activity) { create(:activity, trackable: post) }

    subject(:receivers) { Notifications::NewUserPost.receivers(activity) }

    it 'returns users from graetzl' do
      expect(receivers.map(&:id)).to match_array users.map(&:id)
    end
  end

  describe '.condition(activity)' do
    let!(:post) { create(:post, author: create(:user)) }
    let!(:activity) { create(:activity, trackable: post) }

    subject(:condition) { Notifications::NewUserPost.condition activity }

    it 'returns false if author != user' do
      allow(post).to receive(:author) { build :approved_location }
      expect(condition).to eq false
    end

    it 'returns true if author user' do
      expect(condition).to eq true
    end
  end
end
