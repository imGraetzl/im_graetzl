require 'rails_helper'

RSpec.describe District, type: :model do
  let(:district) { build(:district) }

  describe 'default scope' do
    let(:third_district) { create(:district, zip: '1030') }
    let(:first_district) { create(:district, zip: '1010') }
    let(:second_district) { create(:district, zip: '1020') }

    it 'retrieves ordered by zip' do
      expect(District.all).to eq [first_district, second_district, third_district]
    end
  end

  describe '#long_name' do
    let(:named_district) { build(:district, name: 'district', zip: '1234') }

    it 'concats name and zip' do
      expect(named_district.long_name).to eq('district-1234')
    end
  end
end
