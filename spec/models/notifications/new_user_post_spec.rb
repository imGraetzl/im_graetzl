require 'rails_helper'

RSpec.describe Notifications::NewUserPost, type: :model do
  describe '.triggered_by?(activity)' do
    let(:activity) { build :activity, key: 'user_post.create' }
    let(:other_activity) { build :activity, key: 'user_post.comment' }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::NewUserPost.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::NewUserPost.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:graetzl) { create :graetzl }
    let!(:users) { create_list :user, 10, graetzl: graetzl }
    let!(:user_post) { create :user_post, graetzl: graetzl }
    let!(:activity) { create :activity, trackable: user_post }

    subject(:receivers) { Notifications::NewUserPost.receivers activity }

    it 'returns users from graetzl' do
      expect(receivers).to match_array users
    end
  end
end
