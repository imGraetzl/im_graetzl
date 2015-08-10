require 'rails_helper'

RSpec.describe Category, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:category)).to be_valid
  end

  describe 'associations' do
    let(:category) { build_stubbed(:category) }

    it 'has meetings' do
      expect(category).to respond_to(:meetings)
    end

    it 'has locations' do
      expect(category).to respond_to(:locations)
    end
  end

  describe 'attributes' do
    let(:category) { build(:category) }

    it 'has context' do
      expect(category).to respond_to(:context)
    end
  end
end
