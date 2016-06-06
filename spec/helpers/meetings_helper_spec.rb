require 'rails_helper'

RSpec.describe MeetingsHelper, type: :helper do
  describe '#meeting_place' do
    let(:placeholder) { "<strong>Ort steht noch nicht fest...</strong>" }

    subject(:place) { helper.meeting_place meeting }

    context 'without address or location' do
      let(:meeting) { build_stubbed :meeting, address: nil, location: nil }

      it 'returns placeholder' do
        expect(place).to include placeholder
      end
    end
    context 'with only location' do
      let(:meeting) { build_stubbed :meeting, address: nil, location: location }

      context 'when location with address' do
        let(:address) { build_stubbed :address, description: '' }
        let(:location) { build_stubbed :location, address: address }

        it 'returns location name' do
          expect(place).to include location.name
        end

        it 'returns location address' do
          expect(place).to include address.street_name
          expect(place).to include address.street_number
        end
      end
      context 'when location without address' do
        let(:location) { build_stubbed :location, address: nil }

        it 'returns location.name' do
          expect(place).to include location.name
        end
      end
    end
    context 'with only address' do
      let(:meeting) { build_stubbed :meeting, address: address }

      context 'when empty address' do
        let(:address) { build_stubbed :address, street_name: '', description: '' }

        it 'returns placeholder' do
          expect(place).to include placeholder
        end
      end
      context 'when address with description' do
        let(:address) { build_stubbed :address, street_name: '', description: 'hello' }

        it 'returns description' do
          expect(place).to include address.description
        end
      end
    end
    context 'with address and location' do
      let(:location) { build_stubbed :location }
      let(:meeting) { build_stubbed :meeting, address: address, location: location }

      context 'with address description' do
        let(:address) { build_stubbed :address, description: 'hello' }

        it 'returns description' do
          expect(place).to include address.description
        end
      end
      context 'without address description' do
        let(:address) { build_stubbed :address, description: '' }

        it 'returns location name' do
          expect(place).to include location.name
        end
      end
    end
  end
end
