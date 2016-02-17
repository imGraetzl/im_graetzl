require 'rails_helper'

RSpec.describe OperatingRange, type: :model do
  it 'has a valid factory' do
    expect(build :operating_range).to be_valid
  end
end
