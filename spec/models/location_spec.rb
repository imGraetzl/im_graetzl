require 'rails_helper'

RSpec.describe Location, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:location)).to be_valid
  end

  describe 'scope' do
    describe ':available' do
      let!(:basic_location) { create(:location_basic) }
      let!(:pending_location) { create(:location_pending) }
      let!(:managed_location) { create(:location_managed) }
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

    it 'is invalid without graetzl' do
      expect(build(:location, graetzl: nil)).not_to be_valid
    end
  end

  describe 'macros' do
    let(:location) { create(:location) }

    it 'has friendly_id' do
      expect(location).to respond_to(:slug)
    end

    it 'has state' do
      expect(location).to respond_to(:state)
    end

    it 'has avatar with content_type' do
      expect(location).to respond_to(:avatar)
      expect(location).to respond_to(:avatar_content_type)
    end

    it 'has cover_photo with content_type' do
      expect(location).to respond_to(:cover_photo)
      expect(location).to respond_to(:cover_photo_content_type)
    end
  end
  
  describe 'associations' do
    let(:location) { create(:location) }

    it 'has graetzl' do
      expect(location).to respond_to(:graetzl)
    end

    it 'has address' do
      expect(location).to respond_to(:address)
    end

    it 'has users' do
      expect(location).to respond_to(:users)
    end

    it 'has categories' do
      expect(location).to respond_to(:categories)
    end

    it 'has contact' do
      expect(location).to respond_to(:contact)
    end

    it 'has meetings' do
      expect(location).to respond_to(:meetings)
    end

    it 'has activities' do
      expect(location).to respond_to(:activities)
    end

    describe 'destroy callbacks' do
      describe 'address' do
        let!(:address) { create(:address, addressable: location) }
        before do
          location.address = address
          location.save
        end

        it 'destroys address' do
          expect(Address.find(address.id)).not_to be_nil
          location.destroy
          expect(Address.find_by_id(address.id)).to be_nil
        end
      end

      describe 'users / location_onwerships' do
        before do
          3.times { create(:location_ownership, location: location) }
        end

        it 'destroys location_ownerships' do
          location_ownerships = location.location_ownerships
          location_ownerships.each do |location_ownership|
            expect(LocationOwnership.find(location_ownership.id)).to be_present
          end
          location.destroy
          location_ownerships.each do |location_ownership|
            expect(LocationOwnership.find_by_id(location_ownership.id)).to be_nil
          end
        end
      end

      describe 'contact' do
        let!(:contact) { create(:contact, location: location) }
        before do
          location.contact = contact
          location.save
        end

        it 'destroys contact' do
          contact = location.contact
          expect(Contact.find(contact.id)).to be_present
          location.destroy
          expect(Contact.find_by_id(contact.id)).to be_nil
        end
      end

      describe 'notifications and activity' do
        before do
          3.times do
            activity = create(:activity, trackable: location, key: 'location.something')
            3.times{ create(:notification, activity: activity) }
          end
        end

        it 'destroys associated activity and notifications' do
          expect(PublicActivity::Activity.count).to eq 3
          expect(Notification.count).to eq 9

          location.destroy

          expect(Notification.count).to eq 0
          expect(PublicActivity::Activity.count).to eq 0
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

      it 'logs :approve activity' do
        PublicActivity.with_tracking do
          expect(location.activities).to be_empty
          location.approve
          location.reload
          expect(location.activities).not_to be_empty
          expect(location.activities.last.key).to eq 'location.approve'
        end
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

  describe '#request_ownership' do

    shared_examples :a_successfull_ownership_request do

      it 'creates new location_onwership record' do
        expect{
          location.request_ownership(user)
        }.to change(LocationOwnership, :count).by 1
      end

      describe 'location' do
        before { location.request_ownership(user) }

        it 'has user' do
          expect(location.reload.users).to include(user)
        end
      end

      describe 'location_ownership' do
        subject(:location_ownership) { location.request_ownership(user) }

        it 'is location_ownership object' do
          expect(location_ownership).to be_instance_of(LocationOwnership)
        end

        it 'has state :pending' do
          expect(location_ownership.pending?).to be true
        end
      end
    end

    shared_examples :an_unsuccessfull_ownership_request do

      it 'does not create location_onwership record' do
        expect{
          location.request_ownership(user)
        }.not_to change{LocationOwnership.count}
      end

      it 'returns nothing' do
        expect(location.request_ownership(user)).to be nil
      end
    end

    context 'when business user' do
      let(:user) { create(:user_business) }

      context 'when location pending' do
        let(:location) { create(:location_pending) }
        it_behaves_like :a_successfull_ownership_request

        context 'with existing ownership' do
          before { location.users << user }
          it_behaves_like :an_unsuccessfull_ownership_request
        end
      end

      context 'when location managed' do
        let(:location) { create(:location_managed) }
        it_behaves_like :a_successfull_ownership_request
        
        context 'with existing ownership' do
          before { location.users << user }
          it_behaves_like :an_unsuccessfull_ownership_request
        end
      end

      context 'when location basic' do
        let(:location) { create(:location_basic) }
        it_behaves_like :an_unsuccessfull_ownership_request

        context 'with existing ownership' do
          before { location.users << user }
          it_behaves_like :an_unsuccessfull_ownership_request
        end
      end
    end

    context 'when non business user' do
      let(:user) { create(:user) }
      let(:location) { create(:location_managed) }

      it_behaves_like :an_unsuccessfull_ownership_request
    end
  end
end
