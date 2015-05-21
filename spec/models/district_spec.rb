require 'rails_helper'

RSpec.describe District, type: :model do
  let(:district) { build(:district) }

  describe '#long_name' do
    let(:named_district) { build(:district, name: 'district', zip: '1234') }

    it 'concats name and zip' do
      expect(named_district.long_name).to eq('district-1234')
    end
  end
end
