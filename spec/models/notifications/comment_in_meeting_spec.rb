require 'rails_helper'

RSpec.describe Notifications::CommentInMeeting, type: :model do
  describe '.triggered_by?(activity)' do
    let(:activity) { build :activity, key: 'meeting.comment' }
    let(:other_activity) { build :activity, key: 'meeting.create' }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::CommentInMeeting.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::CommentInMeeting.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:meeting) { create :meeting  }
    let!(:users) { create_list :user, 5 }
    let!(:activity) { create :activity, trackable: meeting }

    before do
      users.each{|user| create(:going_to, user: user, meeting: meeting)}
    end

    subject(:receivers) { Notifications::CommentInMeeting.receivers(activity) }

    it 'returns meeting users' do
      expect(receivers).to match_array users
    end
  end

  describe '.condition(activity)' do
    subject(:condition) { Notifications::CommentInMeeting.condition build(:activity) }

    it 'returns always true' do
      expect(condition).to eq true
    end
  end
end
