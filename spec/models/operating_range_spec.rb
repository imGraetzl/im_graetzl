require 'rails_helper'

RSpec.describe OperatingRange, type: :model do
  it 'has a valid factory' do
    expect(build :operating_range, operator: build(:graetzl)).to be_valid
    expect(build :operating_range, operator: build(:initiative)).to be_valid
  end
end
