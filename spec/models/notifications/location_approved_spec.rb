require 'rails_helper'

RSpec.describe Notifications::LocationApproved, type: :model do
  describe '.triggered_by?(activity)' do
    let(:activity) { build :activity, key: 'location.approve' }
    let(:other_activity) { build :activity, key: 'location.create' }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::LocationApproved.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::LocationApproved.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:location) { create :location, :approved }
    let(:users) { create_list :user, 3 }
    let!(:activity) { create :activity, trackable: location }

    before do
      users.each{|user| create(:location_ownership, user: user, location: location)}
    end

    subject(:receivers) { Notifications::LocationApproved.receivers(activity) }

    it 'returns location users' do
      expect(receivers).to match_array users
    end
  end

  describe '.condition(activity)' do
    let(:activity) { build :activity, trackable: build(:location, :approved) }

    subject(:condition) { Notifications::LocationApproved.condition activity }

    it 'returns always true' do
      expect(condition).to eq true
    end
  end
end
