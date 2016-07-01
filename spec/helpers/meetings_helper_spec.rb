require 'rails_helper'

RSpec.describe MeetingsHelper, type: :helper do
  describe '#meeting_initiator' do
    let(:meeting) { build_stubbed :meeting }

    subject(:initiator) { helper.meeting_initiator meeting }

    it 'returns nil when no initiator' do
      expect(initiator).to be_nil
    end

    it 'returns location avatar and name when location initiator' do
      location = build_stubbed :location, name: 'powerlocation'
      allow(meeting).to receive(:responsible_user_or_location){ location }
      expect(initiator).to include(location.name, 'location')
    end

    it 'returns user avatar and username when user initiator' do
      user = build_stubbed :user, username: 'poweruser'
      allow(meeting).to receive(:responsible_user_or_location){ user }
      expect(initiator).to include(user.username, 'user')
    end
  end
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
        let(:location) { build_stubbed :location, name: 'powerlocation', address: address }

        it 'returns location name' do
          expect(place).to include location.name
        end

        it 'returns location address' do
          expect(place).to include address.street_name
          expect(place).to include address.street_number
        end
      end
      context 'when location without address' do
        let(:location) { build_stubbed :location, name: 'powerlocation', address: nil }

        it 'returns location.name' do
          expect(place).to include location.name
        end
      end
    end
    context 'with only address' do
      let(:meeting) { build_stubbed :meeting, address: address, location: nil }

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
      let(:location) { build_stubbed :location, name: 'powerlocation' }
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
  describe '#meeting_new_headline' do
    it 'contains location name when parent location' do
      location = build :location, name: 'location1'
      expect(helper.meeting_new_headline location).to include location.name
    end
    it 'contains graetzl name when parent graetzl' do
      graetzl = build(:graetzl)
      expect(helper.meeting_new_headline graetzl).to include graetzl.name
    end
    it 'returns "Neues Treffen.." when parent nil' do
      expect(helper.meeting_new_headline nil).to include 'Ein neues Treffen, wie schön!'
    end
  end
end
