require 'rails_helper'

RSpec.describe Location, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:location)).to be_valid
    expect(build_stubbed(:approved_location)).to be_valid
  end

  describe 'validations' do
    it 'is invalid without name' do
      expect(build(:location, name: '')).not_to be_valid
    end

    it 'is invalid without graetzl' do
      expect(build(:location, graetzl: nil)).not_to be_valid
    end

    it 'is invalid without category' do
      expect(build(:location, category: nil)).not_to be_valid
    end
  end

  describe 'attr macros' do
    let(:location) { create(:location) }

    it 'has friendly_id' do
      expect(location).to respond_to(:slug)
    end

    it 'has state default :pending' do
      expect(location).to respond_to(:state)
      expect(location.pending?).to be true
    end

    it 'has meeting_permission, default :meetable' do
      expect(location).to respond_to(:meeting_permission)
      expect(location.meetable?).to be true
    end

    it 'has avatar with content_type' do
      expect(location).to respond_to(:avatar)
      expect(location).to respond_to(:avatar_content_type)
    end

    it 'has cover_photo with content_type' do
      expect(location).to respond_to(:cover_photo)
      expect(location).to respond_to(:cover_photo_content_type)
    end

    it 'has product_list (tags)' do
      expect(location).to respond_to :product_list
    end
  end

  describe 'associations' do
    let(:location) { create(:location) }

    it 'has graetzl' do
      expect(location).to respond_to(:graetzl)
    end

    describe 'address' do
      it 'has address' do
        expect(location).to respond_to(:address)
      end

      it 'is destroyed with location' do
        create :address, addressable: location
        expect{
          location.destroy
        }.to change(Address, :count).by -1
      end
    end

    describe 'users' do
      it 'has users' do
        expect(location).to respond_to(:users)
      end

      it 'destroys ownerships with location' do
        create_list :location_ownership, 3, location: location
        expect{
          location.destroy
        }.to change(LocationOwnership, :count).by -3
      end
    end

    it 'has category' do
      expect(location).to respond_to(:category)
    end

    describe 'contact' do
      it 'has contact' do
        expect(location).to respond_to(:contact)
      end

      it 'is destroyed with location' do
        create :contact, location: location
        expect{
          location.destroy
        }.to change(Contact, :count).by -1
      end
    end

    it 'has meetings' do
      expect(location).to respond_to(:meetings)
    end

    describe 'activities' do
      it 'has activities' do
        expect(location).to respond_to(:activities)
      end

      it 'destroys activities and notifications with location' do
        3.times do
          activity = create(:activity, trackable: location, key: 'location.something')
          create_list(:notification, 3, activity: activity)
        end
        expect(PublicActivity::Activity.count).to eq 3
        expect(Notification.count).to eq 9
        location.destroy
        expect(Notification.count).to eq 0
        expect(PublicActivity::Activity.count).to eq 0
      end
    end

    describe 'posts' do
      it 'has posts' do
        expect(location).to respond_to(:posts)
      end

      it 'destroys posts with location' do
        create_list(:post, 3, author: location)
        expect{
          location.destroy
        }.to change(Post, :count).by -3
      end
    end

    it 'has billing_address' do
      expect(location).to respond_to :billing_address
    end
  end

  describe 'scopes' do
    describe 'paginate_index' do
      before { create_list(:location, 60) }

      context 'with page param = 1' do
        subject(:locations) { Location.paginate_index(1) }

        it 'returns newest 14' do
          expect(locations).to eq Location.order(id: :desc).first(14)
        end
      end

      context 'with page param = 2' do
        subject(:locations) { Location.paginate_index(2) }

        it 'returns newest 15 with offset 14' do
          expect(locations).to eq Location.order(id: :desc).offset(14).first(15)
        end
      end
    end
  end

  describe '#show_meeting_button' do
    let!(:location) { create(:location) }

    context 'when meeting_permission meetable' do
      before { location.meetable! }

      it 'returns true for any user' do
        expect(location.show_meeting_button(build(:user))).to eq true
      end
    end

    context 'when meeting_permission owner_meetable' do
      let(:owner) { create(:user) }
      before do
        location.owner_meetable!
        create(:location_ownership, location: location, user: owner)
      end

      it 'returns false for random user' do
        expect(location.show_meeting_button(build(:user))).to eq false
      end

      it 'returns true for owner' do
        expect(location.show_meeting_button(owner)).to eq true
      end
    end

    context 'when meeting_permission non_meetable' do
      before { location.non_meetable! }

      it 'returns false for any user' do
        expect(location.show_meeting_button(build(:user))).to eq false
      end
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

  describe '#meta_description' do
    let(:address) { create(:address,
                            street_name: 'street',
                            street_number: '2/2/2',
                            zip: '1050',
                            city: 'Wien') }

    context 'when address and description' do
      let(:location) { build(:location, address: address) }

      subject(:meta) { location.meta_description }

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

      subject(:meta) { location.meta_description }

      it 'is not longer than 155 chars' do
        expect(meta.size).to be <= 155
      end

      it 'contains part of the description' do
        expect(meta).to include(location.description[0..50])
      end
    end
  end

  describe '#boss' do
    let(:location) { create :location }
    let(:owner) { create :user }
    before do
      create(:location_ownership, user: owner, location: location)
      create_list(:location_ownership, 3, location: location)
    end

    it 'returs first user' do
      expect(location.users.count).to eq 4
      expect(location.boss).to eq owner
    end
  end
end
