require 'rails_helper'

RSpec.describe User, type: :model do
  
  # check factory
  it 'has a valid factory' do
    expect(build_stubbed(:user)).to be_valid
  end

  # validations
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

    describe 'avatar' do
      let(:user) { create(:user, graetzl: create(:graetzl)) }

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
        before do
          File.open(File.join(Rails.root, 'spec', 'support', 'avatar_test.wrong')) do |f|
            user.avatar = f
          end
        end

        it 'is invalid' do
          expect(user).not_to be_valid
        end

        it 'has default avatar' do
          expect(user.avatar_url).to eq('avatar/default.png')
        end
      end
    end
  end

  # class methods

  # instance methods
  describe '#autosave_associated_records_for_graetzl' do

    context 'when graetzl in db' do
      before do
        @existing_graetzl = create(:graetzl)
      end

      it 'associates with existing graetzl record' do
        user = create(:user, graetzl: build(:graetzl, name: @existing_graetzl.name))
        expect(user.graetzl).to eq(@existing_graetzl)
      end

      it 'does not create new graetzl record' do
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

    context 'when no graetzl in db' do
      #TODO add this edgecase
    end
  end

  describe '#go_to' do
    let(:user) { create(:user) }
    let(:meeting) { create(:meeting) }

    context 'when attendee' do      

      it 'creates new going_to record with default role' do
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
      
      it 'creates going_to record with role initator' do
        expect {
        user.go_to(meeting, GoingTo::ROLES[:initator])
      }.to change(GoingTo, :count).by(1)
      expect(user.going_tos.last.role).to eq(GoingTo::ROLES[:initator])
      end
    end
  end
end