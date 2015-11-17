require 'rails_helper'

RSpec.describe Curator, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:curator)).to be_valid
  end

  describe 'validations' do

    it 'is invalid without graetzl' do
      expect(build(:curator, graetzl: nil)).not_to be_valid
    end

    it 'is invalid without user' do
      expect(build(:curator, user: nil)).not_to be_valid
    end

    it 'is invalid without website' do
      expect(build(:curator, website: nil)).not_to be_valid
    end

    it 'is invalid with non url website' do
      expect(build(:curator, website: Faker::Lorem.sentence)).not_to be_valid
    end
  end
end
