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

    it 'invalid with starts_at in past' do
      expect(build(:meeting_full, starts_at: 1.day.ago)).not_to be_valid
    end

    it 'invalid with ends_at in past' do
      expect(build(:meeting_full, ends_at: 1.day.ago)).not_to be_valid
    end

    it 'invalid with ends_at before_starts_at' do
      expect(build(:meeting_full, starts_at: Time.now + 1.day, ends_at: Time.now)).not_to be_valid
    end
  end
end