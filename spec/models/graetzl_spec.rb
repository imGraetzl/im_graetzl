require 'rails_helper'

RSpec.describe Graetzl, type: :model do

  it 'has a valid factory' do
    expect(build(:graetzl)).to be_valid
  end

  # instance methods
  describe 'short_name' do
    let(:aspern) { build(:aspern) }
    it 'returns first part of name' do
      expect(aspern.short_name).to eql('Aspern')
    end
  end
end
