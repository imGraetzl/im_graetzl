require 'rails_helper'

RSpec.describe LocationsHelper, type: :helper do

  describe '#location_meta' do
    let(:address) { create(:address,
                            street_name: 'street',
                            street_number: '2/2/2',
                            zip: '1050',
                            city: 'Wien') }

    context 'when address and description' do
      let(:location) { build(:location, address: address) }
      subject(:meta) { helper.location_meta location }

      it 'includes street_name, zip and city' do
        expect(meta).to include(address.street_name, address.zip, address.city)
      end

      it 'includes first part of street_number' do
        expect(meta).to include("#{address.street_name} 2")
        expect(meta).not_to include('/')
      end

      it 'is not longer than 155 chars' do
        expect(meta.size).to be <= 155
      end

      it 'contains part of the description' do
        expect(meta).to include(location.description[0..50])
      end
    end

    context 'without address' do
      let(:location) { build(:location, address: nil) }

      subject(:meta) { helper.location_meta location }

      it 'is not longer than 155 chars' do
        expect(meta.size).to be <= 155
      end

      it 'contains part of the description' do
        expect(meta).to include(location.description[0..50])
      end
    end

    context 'without address or description' do
      let(:location) { build(:location, address: nil, description: '') }

      it 'returns blank string' do
        expect(helper.location_meta location).to eq ''
      end
    end
  end
end
