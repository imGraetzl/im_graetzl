require 'rails_helper'

RSpec.describe Location, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:location)).to be_valid
  end
  
  describe 'associations' do
    let(:location) { create(:location) }

    it 'has friendly_id' do
      expect(location).to respond_to(:slug)
    end

    it 'has avatar' do
      expect(location).to respond_to(:avatar)
    end

    it 'has cover_photo' do
      expect(location).to respond_to(:cover_photo)
    end

    it 'has address' do
      expect(location).to respond_to(:address)
    end

    describe 'destroy associated records' do
      before do
        create(:address, addressable: location)
      end

      it 'has address' do
        expect(location.address).not_to be_nil
      end

      it 'destroys address' do
        address = location.address
        location.destroy
        expect(Address.find_by_id(address.id)).to be_nil
      end
    end
  end
end
