require 'rails_helper'

RSpec.describe Location, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:location)).to be_valid
  end

  describe 'scope' do
    describe ':all_pending' do
      let!(:basic_location) { create(:location) }
      let!(:requested_location) { create(:location,
        state: Location.states[:requested]) }
      let!(:pending_location) { create(:location,
        state: Location.states[:pending]) }
      let!(:managed_location) { create(:location,
        state: Location.states[:managed]) }

      it 'includes :pending locations' do
        expect(Location.all_pending).to include(pending_location)
      end

      it 'includes :requested locations' do
        expect(Location.all_pending).to include(requested_location)
      end

      it 'does not include :basic and :managed locations' do
        expect(Location.all_pending).not_to include(basic_location)
        expect(Location.all_pending).not_to include(managed_location)
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

  describe 'state' do
    describe ':requested' do
      let(:location) { create(:location, state: Location.states[:requested]) }
      let!(:pending_ownership) { create(:location_ownership,
        location: location, user: create(:user, role: User.roles[:business]),
        state: LocationOwnership.states[:pending]) }
      let!(:requested_ownership) { create(:location_ownership,
        location: location, user: create(:user, role: User.roles[:business]),
        state: LocationOwnership.states[:requested]) }

      it 'can not be adopted' do
        expect(location.may_adopt?).to be_falsey
        expect{ location.adopt }.to raise_error(AASM::InvalidTransition)
      end

      it 'can not be requested' do
        expect(location.may_request?).to be_falsey
        expect{ location.request }.to raise_error(AASM::InvalidTransition)
      end

      it 'can be approved' do
        expect(location.may_approve?).to be_truthy
      end

      context 'when #approve' do
        it 'changes state to :managed' do
          expect{
            location.approve
          }.to change(location, :state).to 'managed'
        end

        it 'updates :pending ownerships' do
          location.approve!
          expect(pending_ownership.reload.approved?).to be_truthy
        end

        it 'does not update :requested ownerships' do
          location.approve
          expect(requested_ownership.reload.approved?).to be_falsey
        end
      end

      context 'when #reject' do
        it 'changes state to :rejected' do
          expect{
            location.reject
          }.to change(location, :state).to 'rejected'
        end

        it 'does not change :pending and :requested ownerships' do
          location.reject
          expect(pending_ownership.reload.pending?).to be_truthy
          expect(requested_ownership.reload.requested?).to be_truthy
        end
      end
    end

    describe ':basic' do
      let(:location) { create(:location) }

      it 'is initial state' do
        expect(location.basic?).to be_truthy
      end

      it 'can be adopted' do
        expect(location.may_adopt?).to be_truthy
      end

      it 'can be requested' do
        expect(location.may_request?).to be_truthy
      end

      it 'can not be approved' do
        expect(location.may_approve?).to be_falsey
        expect{ location.approve }.to raise_error(AASM::InvalidTransition)
      end

      context 'when #request' do
        it 'changes state to :requested' do
          expect{
            location.request
          }.to change(location, :state).to 'requested'
        end
      end

      context 'when #adopt' do
        it 'changes state to :pending' do
          expect{
            location.adopt
          }.to change(location, :state).to 'pending'
        end
      end
    end

    describe ':pending' do
      let(:location) { create(:location, state: Location.states[:pending]) }      

      it 'can be approved' do
        expect(location.may_approve?).to be_truthy
      end

      it 'can not be adopted' do
        expect(location.may_adopt?).to be_falsey
        expect{ location.adopt }.to raise_error(AASM::InvalidTransition)
      end

      it 'can not be requested' do
        expect(location.may_request?).to be_falsey
        expect{ location.request }.to raise_error(AASM::InvalidTransition)
      end

      context 'when #approve' do
        let!(:pending_ownership) { create(:location_ownership,
          location: location, user: create(:user, role: User.roles[:business]),
          state: LocationOwnership.states[:pending]) }
        let!(:requested_ownership) { create(:location_ownership,
          location: location, user: create(:user, role: User.roles[:business]),
          state: LocationOwnership.states[:requested]) }

        it 'changes state to :managed' do
          expect{
            location.approve
          }.to change(location, :state).to 'managed'
        end

        it 'updates :pending ownerships' do
          location.approve!
          expect(pending_ownership.reload.approved?).to be_truthy
        end

        it 'does not update :requested ownerships' do
          location.approve
          expect(requested_ownership.reload.approved?).to be_falsey
        end
      end

      context 'when #reject' do
        it 'changes state to :basic' do
          expect{
            location.reject
          }.to change(location, :state).to 'basic'
        end

        context 'when attributes have changed' do

          it 'resets attributes' do
            old_name = location.name
            new_name = 'new name'
            location.update(name: new_name)
            expect(location.name).to eq new_name
            location.reject!
            expect(location.name).to eq old_name
          end

          it 'resets address_attributes' do
            old_name = location.address.street_name
            new_name = 'new street'
            location.address.update(street_name: new_name)
            expect(location.address.street_name).to eq new_name
            location.reject!
            expect(location.address.street_name).to eq old_name
          end

          it 'resets contact_attributes' do
            old_email = location.contact.email
            new_email = 'new@mail.at'
            location.contact.update(email: new_email)
            expect(location.contact.email).to eq new_email
            location.reject!
            expect(location.contact.email).to eq old_email
          end

        end

        # it 'does not change :pending and :requested ownerships' do
        #   location.reject
        #   expect(pending_ownership.reload.pending?).to be_truthy
        #   expect(requested_ownership.reload.requested?).to be_truthy
        # end
      end
    end

    describe ':rejected' do
      let(:location) { create(:location, state: Location.states[:rejected]) }
      let!(:pending_ownership) { create(:location_ownership,
        location: location, user: create(:user, role: User.roles[:business]),
        state: LocationOwnership.states[:pending]) }
      let!(:requested_ownership) { create(:location_ownership,
        location: location, user: create(:user, role: User.roles[:business]),
        state: LocationOwnership.states[:requested]) }

      it 'can be approved' do
        expect(location.may_approve?).to be_truthy
      end

      it 'can not be adopted' do
        expect(location.may_adopt?).to be_falsey
        expect{ location.adopt }.to raise_error(AASM::InvalidTransition)
      end

      it 'can not be requested' do
        expect(location.may_request?).to be_falsey
        expect{ location.request }.to raise_error(AASM::InvalidTransition)
      end

      context 'when #approve' do

        it 'changes state to :managed' do
          expect{
            location.approve
          }.to change(location, :state).to 'managed'
        end

        it 'updates :pending ownerships' do
          location.approve!
          expect(pending_ownership.reload.approved?).to be_truthy
        end

        it 'does not update :requested ownerships' do
          location.approve
          expect(requested_ownership.reload.approved?).to be_falsey
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
