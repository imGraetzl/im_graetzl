require 'rails_helper'

RSpec.describe Notifications::AlsoCommentedMeeting, type: :model do

  describe '.triggered_by?(activity)' do
    let(:activity) { build_stubbed(:activity, key: 'meeting.comment') }
    let(:other_activity) { build_stubbed(:activity, key: 'meeting.create') }

    it 'returns true if activity.key matches TRIGGER_KEY' do
      expect(Notifications::AlsoCommentedMeeting.triggered_by?(activity)).to eq true
    end

    it 'returns false if activity.key does not match TRIGGER_KEY' do
      expect(Notifications::AlsoCommentedMeeting.triggered_by?(other_activity)).to eq false
    end
  end

  describe '.receivers(activity)' do
    let!(:meeting) { create(:meeting) }
    let!(:users) { create_list(:user, 5) }
    let!(:owner) { create(:user) }
    let!(:activity) { create(:activity, trackable: meeting, owner: owner) }

    before do
      users.each{|user| create(:comment, user: user, commentable: meeting) }
      create(:comment, user: owner, commentable: meeting)
    end

    subject(:receivers) { Notifications::AlsoCommentedMeeting.receivers(activity) }

    it 'returns all previous commenters' do
      expect(receivers.map(&:id)).to match_array(users.map(&:id))
    end

    it 'excludes owner of activity' do
      expect(receivers.map(&:id)).not_to include(owner.id)
    end
  end

  describe '.condition(activity)' do
    let(:activity) { build(:activity) }

    subject(:condition) { Notifications::AlsoCommentedMeeting.condition activity }

    it 'returns always true' do
      expect(condition).to eq true
    end
  end
end
