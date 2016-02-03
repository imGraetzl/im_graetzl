require 'rails_helper'

RSpec.describe Notifications::NewMeeting, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:notification_new_meeting)).to be_valid
  end

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

  describe '#mail_vars' do
    let(:activity) { build_stubbed(:activity, trackable: build_stubbed(:meeting), owner: build_stubbed(:user)) }
    let(:notification) { build_stubbed(:notification_new_meeting, activity: activity) }

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
    let(:notification) { build_stubbed(:notification_new_meeting, activity: activity) }

    it 'implements #mail_subject' do
      expect(notification).to respond_to :mail_subject
    end

    it 'contains meeting graetzl_name' do
      expect(notification.mail_subject).to include(activity.trackable.graetzl.name)
    end
  end
end
