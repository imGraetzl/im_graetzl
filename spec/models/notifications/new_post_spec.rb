require 'rails_helper'

RSpec.describe Notifications::NewPost, type: :model do

  describe '.triggered_by?(activity)' do
    let(:activity) { build_stubbed(:activity, key: 'post.create') }
    let(:other_activity) { build_stubbed(:activity, key: 'post.comment') }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::NewPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::NewPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:graetzl) { create(:graetzl) }
    let!(:users) { create_list(:user, 10, graetzl: graetzl) }
    let!(:post) { create(:post, graetzl: graetzl) }
    let!(:activity) { create(:activity, trackable: post) }

    subject(:receivers) { Notifications::NewPost.receivers(activity) }

    it 'returns users from graetzl' do
      expect(receivers.map(&:id)).to match_array users.map(&:id)
    end
  end

  describe '.condition(activity)' do
    let(:activity) { build(:activity) }

    subject(:condition) { Notifications::NewPost.condition activity }

    it 'returns always true' do
      expect(condition).to eq true
    end
  end
end
