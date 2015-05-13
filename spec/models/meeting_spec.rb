require 'rails_helper'

RSpec.describe Meeting, type: :model do
  
  # check factory
  it 'has a valid factory' do
    expect(build_stubbed(:meeting_full)).to be_valid
  end

  # validations
  describe 'validations' do
    it 'invalid without name' do
      expect(build(:meeting_full, name: nil)).not_to be_valid
    end

    it 'invalid without description' do
      expect(build(:meeting_full, description: nil)).not_to be_valid
    end

    # it 'invalid with starts_at in past' do
    #   expect(build(:meeting_full, starts_at: 1.day.ago)).not_to be_valid
    # end

    # it 'invalid with ends_at in past' do
    #   expect(build(:meeting_full, ends_at: 1.day.ago)).not_to be_valid
    # end

    # it 'invalid with ends_at before_starts_at' do
    #   expect(build(:meeting_full, starts_at: Time.now + 1.day, ends_at: Time.now)).not_to be_valid
    # end
  end

  # instance methods
  describe '#complete_datetimes' do
    let(:meeting) { build(:meeting) }

    context 'when no ends_at_time set' do
      before { meeting.complete_datetimes }

      it 'does not set ends_at_date and ends_at_time' do
        expect(meeting.ends_at_date).to be_nil
        expect(meeting.ends_at_time).to be_nil
      end

      it 'does not set ends_at' do
        expect(meeting.ends_at).to be_nil
      end
    end

    context 'when ends_at_time and no starts_at set' do
      before do
        meeting.ends_at_time = '20:00'
        meeting.complete_datetimes
      end

      it 'sets ends_at_date to today' do
        expect(meeting.ends_at_date.strftime('%Y-%m-%d')).to eq(Time.now.strftime('%Y-%m-%d'))
      end

      it 'keeps ends_at_time' do
        expect(meeting.ends_at_time.strftime('%H:%M')).to eq('20:00')
      end
    end

    context 'when ends_at_time and starts_at_time set' do
      before do
        meeting.ends_at_time = '20:00'
        meeting.starts_at_time = '19:00'
        meeting.complete_datetimes
      end

      it 'sets ends_at_date to today' do
        expect(meeting.ends_at_date.strftime('%Y-%m-%d')).to eq (Time.now.strftime('%Y-%m-%d'))
      end

      it 'keeps ends_at_time' do
        expect(meeting.ends_at_time.strftime('%H:%M')).to eq ('20:00')
      end
    end

    context 'when ends_at_time set and starts_at set' do
      before do
        meeting.ends_at_time = '20:00'
        meeting.starts_at_date = '2020-01-01'
        meeting.starts_at_time = '19:00'
        meeting.complete_datetimes
      end

      it 'sets ends_at_date to starts_at_date' do
        expect(meeting.ends_at_date.strftime('%Y-%m-%d')).to eq ('2020-01-01')
      end

      it 'keeps ends_at_time' do
        expect(meeting.ends_at_time.strftime('%H:%M')).to eq ('20:00')
      end
    end
  end
end