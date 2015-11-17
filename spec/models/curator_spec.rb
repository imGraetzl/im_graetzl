require 'rails_helper'

RSpec.describe Curator, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:curator)).to be_valid
  end
end
