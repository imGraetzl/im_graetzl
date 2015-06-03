require 'rails_helper'

RSpec.describe GoingTo, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:going_to)).to be_valid
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