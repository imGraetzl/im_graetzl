require 'rails_helper'
require 'carrierwave/test/matchers'

RSpec.describe User, type: :model do
  include CarrierWave::Test::Matchers
  
  it 'has a valid factory' do
    expect(build_stubbed(:user)).to be_valid
  end

  describe 'validations' do
    it 'invalid without username' do
      expect(build(:user, username: nil)).not_to be_valid
    end

    it 'invalid with dublicate username' do
      first_user = create(:user)
      expect(build(:user, username: first_user.username)).not_to be_valid
    end

    it 'invalid without first_name' do
      expect(build(:user, first_name: nil)).not_to be_valid
    end

    it 'invalid without last_name' do
      expect(build(:user, last_name: nil)).not_to be_valid
    end

    it 'invalid without graetzl' do
      expect(build(:user, graetzl: nil)).not_to be_valid
    end
  end

  describe 'associations' do
    let(:user) { create(:user) }

    it 'has address' do
      expect(user).to respond_to(:address)
    end

    it 'has graetzl' do
      expect(user).to respond_to(:graetzl)
    end

    it 'has meetings' do
      expect(user).to respond_to(:meetings)
    end

    it 'has posts' do
      expect(user).to respond_to(:posts)
    end

    it 'has comments' do
      expect(user).to respond_to(:comments)
    end

    describe 'destroy associated records' do
      before { user.create_address(attributes_for(:address)) }

      it 'has address' do
        expect(user.address).not_to be_nil
      end

      it 'destroys address with user' do
        address = user.address
        user.destroy
        expect(Address.find_by_id(address.id)).to be_nil
      end
    end
  end

  describe '.avatar' do
    let(:user) { create(:user) }

    context 'when image filetype (png, jpg..)' do
      before do
        File.open(File.join(Rails.root, 'spec', 'support', 'avatar_test.png')) do |f|
          user.avatar = f
        end
      end
      after { user.avatar.remove! }

      it 'is valid' do
        expect(user).to be_valid
      end

      it 'has individual avatar' do
        expect(user.avatar.identifier).to eq('avatar_test.png')
      end
    end

    context 'when non-image filetype' do
      it 'raises error' do
        expect{
          File.open(File.join(Rails.root, 'spec', 'support', 'avatar_test.wrong')) do |f|
            user.avatar = f
          end
          }.to raise_error(CarrierWave::IntegrityError)
      end
    end
  end

  describe '#autosave_associated_records_for_graetzl' do
    context 'when graetzl in db' do
      before do
        @existing_graetzl = create(:graetzl)
      end

      it 'associates existing graetzl' do
        user = create(:user, graetzl: build(:graetzl, name: @existing_graetzl.name))
        expect(user.graetzl).to eq(@existing_graetzl)
      end

      it 'does not create new graetzl' do
        expect {
          user = create(:user, graetzl: build(:graetzl, name: @existing_graetzl.name))
        }.not_to change(Graetzl, :count)
      end
    end

    context 'when graetzl not in db' do
      before do
        @default_graetzl = create(:graetzl)
      end

      it 'associates with first graetzl record' do
        user = create(:user, graetzl: build(:graetzl))
        expect(user.graetzl).to eq(@default_graetzl)
      end

      it 'does not create new graetzl record' do
        expect {
          user = create(:user, graetzl: build(:graetzl))
        }.not_to change(Graetzl, :count)
      end
    end
  end

  describe '#go_to' do
    let(:user) { create(:user) }
    let(:meeting) { create(:meeting) }

    context 'when attendee' do
      it 'creates new going_to with default role' do
        expect {
          user.go_to(meeting)
        }.to change(GoingTo, :count).by(1)
      expect(user.going_tos.last.role).to eq(GoingTo::ROLES[:attendee])
      end

      it 'adds going_to to user' do
        expect {
          user.go_to(meeting)
        }.to change(user.going_tos, :count).by(1)
      end

      it 'add meeting to user' do
        user.go_to(meeting)
        expect(user.meetings.last).to eq(meeting)
      end
    end

    context 'when initator' do      
      it 'creates going_to with role initator' do
        expect {
        user.go_to(meeting, GoingTo::ROLES[:initator])
      }.to change(GoingTo, :count).by(1)
      expect(user.going_tos.last.role).to eq(GoingTo::ROLES[:initator])
      end
    end
  end

  describe '#initiated?(meeting)' do
    let(:user) { create(:user) }
    let(:meeting) { create(:meeting) }

    context 'when initiator' do
      before do
        create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:initiator])
      end

      it 'returns true' do
        expect(user.initiated?(meeting)).to be_truthy
      end
    end

    context 'when attendee' do
      before do
        create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:attendee])
      end

      it 'returns false' do
        expect(user.initiated?(meeting)).to be_falsey
      end
    end

    context 'when not going' do
      it 'returns false' do
        expect(user.initiated?(meeting)).to be_falsey
      end
    end
  end

  describe '#going_to?(meeting)' do
    let(:user) { create(:user) }
    let(:meeting) { create(:meeting) }

    context 'when initiator' do
      before do
        create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:initiator])
      end

      it 'returns true' do
        expect(user.going_to?(meeting)).to be_truthy
      end
    end

    context 'when attendee' do
      before do
        create(:going_to, user: user, meeting: meeting, role: GoingTo::ROLES[:attendee])
      end

      it 'returns true' do
        expect(user.going_to?(meeting)).to be_truthy
      end
    end

    context 'when not going' do
      it 'returns false' do
        expect(user.going_to?(meeting)).to be_falsey
      end
    end
  end

  describe '#avatar' do
    let(:user) { build_stubbed(:user) }

    context 'when file uploaded' do
      before do
        File.open(File.join(Rails.root, 'spec', 'support', 'avatar_test.png')) do |f|
          user.avatar = f
        end        
      end

      it 'has avatar' do
        expect(user.avatar.identifier).to eq('avatar_test.png')
      end

      it 'has large version' do
        expect(user.avatar.large).to have_dimensions(300, 300)
        expect(user.avatar_url(:large)).to include('large_avatar_test.png')
      end

      it 'has medium version' do
        expect(user.avatar.medium).to have_dimensions(200, 200)
        expect(user.avatar_url(:medium)).to include('medium_avatar_test.png')
      end

      it 'has small version' do
        expect(user.avatar.small).to have_dimensions(100, 100)
        expect(user.avatar_url(:small)).to include('small_avatar_test.png')
      end
    end

    context 'when no file uploaded' do

      it 'returns default avatar' do
        expect(user.avatar_url).to eq('avatar/default.png')
      end

      it 'returns large version' do
        expect(user.avatar_url(:large)).to include('large_default.png')
      end

      it 'returns medium version' do
        expect(user.avatar_url(:medium)).to include('medium_default.png')
      end

      it 'returns small version' do
        expect(user.avatar_url(:small)).to include('small_default.png')
      end
    end
  end
end