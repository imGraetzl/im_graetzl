require 'rails_helper'

RSpec.describe GoingTo, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:going_to)).to be_valid
  end

  describe 'validations' do
    it 'is invalid without user' do
      expect(build(:going_to, user: nil)).not_to be_valid
    end

    it 'is invalid without meeting' do
      expect(build(:going_to, meeting: nil)).not_to be_valid
    end
  end

  describe 'associations' do
    let(:going_to) { create(:going_to) }

    it 'has user' do
      expect(going_to).to respond_to(:user)
    end

    it 'has meeting' do
      expect(going_to).to respond_to(:meeting)      
    end
  end
end