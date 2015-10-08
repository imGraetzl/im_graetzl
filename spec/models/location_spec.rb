require 'rails_helper'

RSpec.describe Location, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:location)).to be_valid
  end

  describe 'scopes' do
    describe ':fit_for_meeting' do
      let!(:approved_and_meetings) { create(:location,
                                    state: Location.states[:approved],
                                    allow_meetings: true) }
      let!(:approved_and_no_meetings) { create(:location,
                                    state: Location.states[:approved],
                                    allow_meetings: false) }
      let!(:pending_and_meetings) { create(:location,
                                    state: Location.states[:pending],
                                    allow_meetings: true) }
      let!(:pending_and_no_meetings) { create(:location,
                                    state: Location.states[:pending],
                                    allow_meetings: false) }

      subject(:locations) { Location.fit_for_meeting }

      it 'returns only approved an allow_meetings location' do
        expect(locations).to include(approved_and_meetings)
      end

      it 'ignores pending' do
        expect(locations).not_to include(pending_and_meetings, pending_and_no_meetings)
      end

      it 'ignores where allow_meetings false' do
        expect(locations).not_to include(approved_and_no_meetings)
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

    it 'has default state :pending' do
      expect(location.pending?).to be true
    end

    it 'has location_type' do
      expect(location).to respond_to(:location_type)
    end

    it 'has default location_type :business' do
      expect(location.business?).to be true
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

  describe '.location_types_for_select' do
    subject(:array_for_select) { Location.location_types_for_select }

    it 'returns multi dimensional array' do
      expect(array_for_select).to be_a(Array)
    end

    it 'contains one array for each type' do
      expect(array_for_select.size).to eq Location.location_types.size
    end

    it 'contains key and trainslation' do
      expect(array_for_select).to contain_exactly(
        ['Kreativ / Unternehmerisch', 'business'],
        ['Öffentlicher Raum', 'public_space'],
        ['Leerstand', 'vacancy'])
    end
  end

  describe '#approve' do
    context 'when location pending' do
      let(:location) { create(:location, state: Location.states[:pending]) }

      it 'changes state to approved' do
        expect{
          location.approve
        }.to change{location.state}.to 'approved'
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
    end

    context 'when location not pending' do
      let(:location) { create(:location, state: Location.states[:approved]) }

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
      let!(:location) { create(:location, state: Location.states[:pending]) }

      it 'returns true' do
        expect(location.reject).to eq true
      end

      it 'destroys record' do
        expect{
          location.reject
        }.to change(Location, :count).by(-1)
      end
    end

    context 'when location approved' do
      let(:location) { create(:location, state: Location.states[:approved]) }

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