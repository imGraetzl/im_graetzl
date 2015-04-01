require 'rails_helper'

RSpec.describe Address, type: :model do

  it 'has a valid factory' do
    expect(FactoryGirl.create(:address)).to be_valid
  end
  it 'is invalid without coordinates'
  it 'is invalid without a user'
  it 'builds a new address from a geojson object'
  it 'matches its respective graetzls'
end
