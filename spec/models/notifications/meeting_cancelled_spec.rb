require 'rails_helper'

RSpec.describe Notifications::MeetingCancelled, type: :model do
  describe '.triggered_by?(activity)' do
    let(:activity) { build :activity, key: 'meeting.cancel' }
    let(:other_activity) { build :activity, key: 'meeting.other' }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::MeetingCancelled.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::MeetingCancelled.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:meeting) { create :meeting }
    let!(:users) { create_list :user, 10 }
    let!(:activity) { create :activity, trackable: meeting }

    before { allow(meeting).to receive(:users) { users } }

    subject(:receivers) { Notifications::MeetingCancelled.receivers(activity) }

    it 'returns users from meeting' do
      expect(receivers).to match_array users
    end
  end

  describe '.condition(activity)' do
    let(:activity) { build(:activity) }

    subject(:condition) { Notifications::MeetingCancelled.condition activity }

    it 'returns always true' do
      expect(condition).to eq true
    end
  end
end
