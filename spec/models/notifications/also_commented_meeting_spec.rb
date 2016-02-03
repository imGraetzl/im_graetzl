require 'rails_helper'

RSpec.describe Notifications::AlsoCommentedMeeting, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:notification_also_commented_meeting)).to be_valid
  end

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

  describe '#mail_vars' do
    let(:activity) { build_stubbed(:activity, trackable: build_stubbed(:meeting), owner: build_stubbed(:user)) }
    let(:notification) { build_stubbed(:notification_also_commented_meeting, activity: activity) }

    it 'implements #mail_vars' do
      expect(notification).to respond_to :mail_vars
    end

    it 'contains owner and meeting vars' do
      expect(notification.mail_vars.keys).to include(:owner_name,
                                                      :owner_url,
                                                      :meeting_name,
                                                      :meeting_url,
                                                      :meeting_starts_at_date,
                                                      :meeting_starts_at_time,
                                                      :meeting_description)
    end
  end

  describe '#mail_subject' do
    let(:activity) { build_stubbed(:activity, trackable: build_stubbed(:meeting), owner: build_stubbed(:user)) }
    let(:notification) { build_stubbed(:notification_also_commented_meeting, activity: activity) }

    it 'implements #mail_subject' do
      expect(notification).to respond_to :mail_subject
    end

    it 'contains meeting graetzl_name' do
      expect(notification.mail_subject).to include(activity.trackable.graetzl.name)
    end
  end
end
