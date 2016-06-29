require 'rails_helper'

RSpec.describe Curator, type: :model do

  it 'has a valid factory' do
    expect(build :curator ).to be_valid
  end

  describe 'validations' do
    it 'is invalid without graetzl' do
      expect(build :curator, graetzl: nil).not_to be_valid
    end
    it 'is invalid without user' do
      expect(build :curator, user: nil).not_to be_valid
    end
    it 'is invalid without name' do
      expect(build :curator, name: nil).not_to be_valid
    end
    it 'is invalid without website' do
      expect(build :curator, website: nil).not_to be_valid
    end
    it 'is invalid without website' do
      expect(build :curator, website: nil).not_to be_valid
    end
    it 'is invalid without valid url for website' do
      expect(build :curator, website: 'google.de').not_to be_valid
    end
  end
end
