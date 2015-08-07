require 'rails_helper'

RSpec.describe Location, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:location)).to be_valid
  end

  describe 'scope' do
    describe ':available' do
      let!(:basic_location) { create(:location,
        state: Location.states[:basic]) }
      let!(:pending_location) { create(:location,
        state: Location.states[:pending]) }
      let!(:managed_location) { create(:location,
        state: Location.states[:managed]) }
      let!(:nil_location) { create(:location) }

      it 'includes basic and managed locations' do
        expect(Location.available).to include(basic_location, managed_location)
      end

      it 'does not include nil and pending locations' do
        expect(Location.available).not_to include(nil_location, pending_location)
      end
    end
  end

  describe 'validations' do
    it 'is invalid without name' do
      expect(build(:location, name: '')).not_to be_valid
    end
  end
  
  describe 'associations' do
    let(:location) { create(:location) }

    it 'has friendly_id' do
      expect(location).to respond_to(:slug)
    end

    it 'has graetzl' do
      expect(location).to respond_to(:graetzl)
    end

    it 'has state' do
      expect(location).to respond_to(:state)
    end

    describe 'avatar' do

      it 'has avatar' do
        expect(location).to respond_to(:avatar)
      end

      it 'has avatar_content_type' do
        expect(location).to respond_to(:avatar_content_type)
      end
    end

    describe 'cover_photo' do

      it 'has cover_photo' do
        expect(location).to respond_to(:cover_photo)
      end

      it 'has cover_photo_content_type' do
        expect(location).to respond_to(:cover_photo_content_type)
      end
    end

    it 'has address' do
      expect(location).to respond_to(:address)
    end

    it 'has users' do
      expect(location).to respond_to(:users)
    end

    describe 'destroy associated records' do
      describe 'users' do
        before do
          3.times { create(:location_ownership, location: location) }
        end

        it 'has location_ownerships' do
          expect(location.location_ownerships.count).to eq 3
        end

        it 'has users' do
          expect(location.users.count).to eq 3
        end

        it 'destroys location_ownerships' do
          location_ownerships = location.location_ownerships
          location.destroy
          location_ownerships.each do |location_ownership|
            expect(LocationOwnerships.find_by_id(location_ownership.id)).to be_nil
          end
        end
      end

      describe 'address' do
        before { create(:address, addressable: location) }

        it 'has address' do
          expect(location.address).not_to be_nil
        end

        it 'destroys address' do
          address = location.address
          location.destroy
          expect(Address.find_by_id(address.id)).to be_nil
        end
      end

      describe 'contact' do
        before { create(:contact, location: location) }

        it 'has contact' do
          expect(location.contact).not_to be_nil
        end

        it 'destroys contact' do
          contact = location.contact
          location.destroy
          expect(Contact.find_by_id(contact.id)).to be_nil
        end
      end
    end
  end

  describe '.reset_or_destroy' do
    context 'when previous version' do
      let!(:location) { create(:location_basic, name: 'basic_name') }

      before do
        location.name = 'pending_name'
        location.pending!
      end

      it 'resets attributes to previous version' do
        Location.reset_or_destroy(location)
        expect(location.reload.name).to eq 'basic_name'
        expect(location.reload.state).to eq 'basic'
      end

      it 'adds new version' do
        expect{
          Location.reset_or_destroy(location)
        }.to change(location.versions, :count).by(1)
      end
    end

    context 'when no previous version' do
      let!(:location) { create(:location_pending) }

        it 'destroys record' do
          expect{
            Location.reset_or_destroy(location)
          }.to change(Location, :count).by(-1)
        end

      it 'adds new version' do
        expect{
          Location.reset_or_destroy(location)
        }.to change(location.versions, :count).by(1)
      end
    end
  end

  describe '#approve' do
    context 'when location pending' do
      let(:location) { create(:location_pending) }

      it 'sets state to managed' do
        expect{
          location.approve
        }.to change{location.state}.to 'managed'
      end

      it 'returns true' do
        expect(location.approve).to be_truthy
      end

      it 'updates ownerships' do
        pending('not implemented yet')
        fail
      end
    end

    context 'when location not pending' do
      let(:location) { create(:location_basic) }

      it 'keeps state' do
        expect{
          location.approve
        }.not_to change(location, :state)
      end

      it 'returns false' do
        expect(location.approve).to eq false
      end
    end
  end

  describe '#reject' do
    context 'when location pending' do
      context 'when previous version exists' do
        let!(:location) { create(:location_basic, name: 'basic_name') }

        before do
          location.name = 'pending_name'
          location.pending!
        end

        it 'returns true' do
          expect(location.reject).to eq true
        end

        it 'resets attributes' do
          expect{
            location.reject
          }.to change{ location.reload.name }.from('pending_name').to('basic_name')
        end

        it 'resets state' do
          expect{
            location.reject
          }.to change{ location.reload.state }.to 'basic'
        end
      end

      context 'when no previous version exists' do
        let!(:location) { create(:location_pending) }

        it 'returns true' do
          expect(location.reject).to eq true
        end

        it 'destroys record' do
          expect{
            location.reject
          }.to change(Location, :count).by(-1)
        end

        it 'marks location as destroyed' do
          location.reject
          expect(location.version.event).to eq 'destroy'
        end
      end
    end

    context 'when location not pending' do
      let(:location) { create(:location_managed) }

      it 'keeps state' do
        expect{
          location.reject
        }.not_to change(location.reload, :state)
      end

      it 'returns false' do
        expect(location.reject).to eq false
      end
    end
  end
end
