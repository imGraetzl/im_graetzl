require 'rails_helper'

RSpec.describe Category, type: :model do
  # check factory
  it 'has a valid factory' do
    expect(build_stubbed(:category)).to be_valid
  end
end
