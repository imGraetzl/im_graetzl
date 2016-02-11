require 'rails_helper'

RSpec.describe BillingAddress, type: :model do
  it 'has a valid factory' do
    expect(build_stubbed :billing_address).to be_valid
  end

  describe 'validations' do
    it 'is invalid without location' do
      expect(build :billing_address, location: nil).not_to be_valid
    end

    it 'is invalid without first_name' do
      expect(build :billing_address, first_name: nil).not_to be_valid
    end

    it 'is invalid without last_name' do
      expect(build :billing_address, last_name: nil).not_to be_valid
    end
  end
end
