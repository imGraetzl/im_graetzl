require 'rails_helper'

RSpec.describe Notifications::CommentInUsersMeeting, type: :model do

  describe '.triggered_by?(activity)' do
    let(:activity) { build_stubbed(:activity, key: 'meeting.comment') }
    let(:other_activity) { build_stubbed(:activity, key: 'meeting.create') }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::CommentInUsersMeeting.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::CommentInUsersMeeting.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:meeting) { create(:meeting) }
    let!(:user) { create(:user) }
    let!(:activity) { create(:activity, trackable: meeting) }

    before do
      create(:going_to, user: user, meeting: meeting, role: GoingTo::roles[:initiator])
      create_list(:going_to, 5, meeting: meeting, role: GoingTo::roles[:attendee])
    end

    subject(:receivers) { Notifications::CommentInUsersMeeting.receivers(activity) }

    it 'returns meeting initiator' do
      expect(receivers).to eq [user]
    end
  end

  describe '.condition(activity)' do
    let!(:meeting) { create(:meeting) }
    let!(:user) { create(:user) }
    let!(:activity) { create(:activity, trackable: meeting, owner: user) }

    subject(:condition) { Notifications::CommentInUsersMeeting.condition activity }

    it 'returns false if initiator == activity owner' do
      allow(meeting).to receive(:initiator) { user }
      expect(condition).to eq false
    end

    it 'returns false if initiator not present' do
      expect(condition).to eq false
    end

    it 'returns true if initiator not activity owner' do
      allow(meeting).to receive(:initiator) { create(:user) }
      expect(condition).to eq true
    end
  end
end
