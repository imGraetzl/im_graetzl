require 'rails_helper'

RSpec.describe Notifications::AttendeeInUsersMeeting, type: :model do

  describe '.triggered_by?(activity)' do
    let(:activity) { build :activity, key: 'meeting.go_to' }
    let(:other_activity) { build :activity, key: 'meeting.create' }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::AttendeeInUsersMeeting.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::AttendeeInUsersMeeting.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:initiator) { create :user }
    let!(:meeting) { create :meeting }
    let!(:user) { create :user }
    let!(:activity) { create(:activity, trackable: meeting, owner: user) }

    before { create(:going_to, :initiator, meeting: meeting, user: initiator) }

    subject(:receivers) { Notifications::AttendeeInUsersMeeting.receivers(activity) }

    it 'returns meeting initiator' do
      expect(receivers.to_a).to match_array [initiator]
    end
  end

  describe '.condition(activity)' do
    let!(:initiator) { create :user }
    let!(:meeting) { create :meeting }
    let!(:user) { create :user }
    let!(:activity) { create(:activity, trackable: meeting, owner: user) }

    subject(:condition) { Notifications::AttendeeInUsersMeeting.condition activity }

    it 'returns false if user initiator' do
      create(:going_to, :initiator, user: initiator, meeting: meeting)
      allow(activity).to receive(:owner_id) { initiator.id }
      expect(condition).to eq false
    end

    it 'returns false if not initiator' do
      expect(condition).to eq false
    end

    it 'returns true initiator not owner' do
      create(:going_to, user: initiator, meeting: meeting, role: GoingTo::roles[:initiator])
      expect(condition).to eq true
    end
  end
end
