require 'rails_helper'

RSpec.describe Meeting, type: :model do
  
  # check factory
  it 'has a valid factory' do
    expect(build_stubbed(:meeting)).to be_valid
  end

  # validations
  describe 'validations' do
    it 'invalid without name' do
      expect(build(:meeting, name: nil)).not_to be_valid
    end

    it 'invalid without description' do
      expect(build(:meeting, description: nil)).not_to be_valid
    end

    it 'invalid without user_initialized' do
      expect(build(:meeting, user_initialized: nil)).not_to be_valid
    end

    it 'invalid without start date' do
      expect(build(:meeting, start: nil)).not_to be_valid
    end

    it 'invalid with start date in past' do
      expect(build(:meeting, start: 1.day.ago)).not_to be_valid
    end

    it 'not invalid without address' do
      expect(build(:meeting, address: nil)).to be_valid
    end

    it 'invalid without graetzl' do
      expect(build(:meeting, graetzls: Array.new)).not_to be_valid
    end
  end
end