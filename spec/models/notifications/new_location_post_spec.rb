require 'rails_helper'

RSpec.describe Notifications::NewLocationPost, type: :model do
  describe '.triggered_by?(activity)' do
    let(:activity) { build :activity, key: 'location_post.create' }
    let(:other_activity) { build :activity, key: 'location_post.comment' }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::NewLocationPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::NewLocationPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:graetzl) { create :graetzl }
    let!(:users) { create_list :user, 10, graetzl: graetzl }
    let!(:location_post) { create :location_post, graetzl: graetzl }
    let!(:activity) { create :activity, trackable: location_post }

    subject(:receivers) { Notifications::NewLocationPost.receivers(activity) }

    it 'returns users from graetzl' do
      expect(receivers).to match_array users
    end
  end
end
