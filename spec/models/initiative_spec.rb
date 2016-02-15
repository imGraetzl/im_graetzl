require 'rails_helper'

RSpec.describe Initiative, type: :model do
  it 'has a valid factory' do
    expect(build :initiative).to be_valid
  end

  describe 'associations' do
    let(:initiative) { create :initiative}

    it 'has graetzls' do
      expect(initiative).to respond_to :graetzls
      expect(initiative).to respond_to :operating_ranges
    end

    it 'has zuckerls' do
      expect(initiative).to respond_to :zuckerls
    end
  end
end
