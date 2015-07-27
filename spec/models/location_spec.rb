require 'rails_helper'

RSpec.describe Location, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:location)).to be_valid
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

    describe 'state' do

      it 'has state' do
        expect(location).to respond_to(:state)
      end

      it 'has initial state :basic' do
        expect(location.basic?).to be_truthy
      end
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

  describe '#request_ownership' do
    context 'when user.business' do
      let(:user) { create(:user, role: User.roles[:business]) }

      context 'when location.basic' do
        let(:location) { build_stubbed(:location, state: Location.states[:basic]) }

        it 'does not create ownership request' do
          expect{
            location.request_ownership(user)
          }.not_to change(LocationOwnership, :count)
        end
      end

      context 'when location.requested' do
        let(:location) { build_stubbed(:location, state: Location.states[:requested]) }

        it 'does not create ownership request' do
          expect{
            location.request_ownership(user)
          }.not_to change(LocationOwnership, :count)
        end
      end

      context 'when location.pending' do
        let(:location) { build_stubbed(:location, state: Location.states[:pending]) }

        it 'creates ownership request' do
          expect{
            location.request_ownership(user)
          }.to change(LocationOwnership, :count).by(1)
        end

        describe 'onwership_request' do
          subject(:ownership_request) { LocationOwnership.last }

          before { location.request_ownership(user) }

          it 'has state :requested' do
            expect(ownership_request.requested?).to be_truthy
          end

          it 'has user associated' do
            expect(ownership_request.user).to eq user
          end
        end
      end

      context 'when location.managed' do
        let(:location) { build_stubbed(:location, state: Location.states[:managed]) }

        it 'creates ownership request' do
          expect{
            location.request_ownership(user)
          }.to change(LocationOwnership, :count).by(1)
        end

        describe 'onwership_request' do
          subject(:ownership_request) { LocationOwnership.last }

          before { location.request_ownership(user) }

          it 'has state :requested' do
            expect(ownership_request.requested?).to be_truthy
          end

          it 'has user associated' do
            expect(ownership_request.user).to eq user
          end
        end
      end
    end

    context 'when user non-business' do
      let(:user) { create(:user, role: nil) }
      let(:location) { build_stubbed(:location, state: Location.states[:managed]) }

      it 'does not create ownership request' do
        expect{
          location.request_ownership(user)
        }.not_to change(LocationOwnership, :count)
      end
    end
  end
end
