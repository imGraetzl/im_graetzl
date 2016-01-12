require 'rails_helper'

RSpec.describe Notifications::NewMeeting, type: :model do

  describe '.receivers(activity)' do
    let!(:graetzl) { create(:graetzl) }
    let!(:users) { create_list(:user, 10, graetzl: graetzl) }
    let!(:meeting) { create(:meeting, graetzl: graetzl) }
    let!(:activity) { create(:activity, trackable: meeting) }

    subject(:receivers) { Notifications::NewMeeting.receivers(activity) }

    it 'returns users from graetzl' do
      expect(receivers.map(&:id)).to match_array users.map(&:id)
    end
  end

  describe '.triggered_by?(activity)' do
    let(:activity) { build_stubbed(:activity, key: 'meeting.create') }
    let(:other_activity) { build_stubbed(:activity, key: 'meeting.other') }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::NewMeeting.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::NewMeeting.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.condition(activity)' do
    let(:activity) { build(:activity) }

    subject(:condition) { Notifications::NewMeeting.condition activity }

    it 'returns always true' do
      expect(condition).to eq true
    end
  end
end
