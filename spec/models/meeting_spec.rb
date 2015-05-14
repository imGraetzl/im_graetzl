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

    it 'invalid with starts_at_date in past' do
      expect(build(:meeting_full, starts_at_date: 1.day.ago)).not_to be_valid
    end

    it 'invalid with ends_at_time before_starts_at_time' do
      expect(build(:meeting_full, starts_at_date: Date.today, starts_at_time: Time.now + 1.hour, ends_at_time: Time.now)).not_to be_valid
    end
  end
end