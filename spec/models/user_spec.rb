require 'rails_helper'

RSpec.describe User, type: :model do
  
  # check factory
  it 'has a valid factory' do
    expect(build_stubbed(:user)).to be_valid
  end

  # validations
  describe 'validations' do
    it 'is invalid without username' do
      expect(build(:user, username: nil)).not_to be_valid
    end

    it 'is invalid with dublicate username' do
      first_user = create(:user)
      expect(build(:user, username: first_user.username)).not_to be_valid
    end

    it 'is invalid without first_name' do
      expect(build(:user, first_name: nil)).not_to be_valid
    end

    it 'is invalid without last_name' do
      expect(build(:user, last_name: nil)).not_to be_valid
    end

    it 'is invalid without graetzl' do
      expect(build(:user, graetzl: nil)).not_to be_valid
    end
  end

  # class methods

  # instance methods
  describe 'autosave graetzl association' do
    context 'when graetzl exists:' do
      it 'associates with existing record in db' do
        existing_graetzl = create(:graetzl)
        other_graetzl = create(:graetzl, name: existing_graetzl.name)
        user = create(:user, graetzl: build(:graetzl, name: existing_graetzl.name))
        expect(user.graetzl).to eq(existing_graetzl)
        expect(user.graetzl).not_to eq(other_graetzl)
      end
    end
    context 'when no graetzl:' do
      it 'associates with default graetzl record in db (first graetzl for now)' do
        default_graetzl = Graetzl.first
        user_graetzl = create(:user, graetzl: build(:graetzl)).graetzl
        expect(user_graetzl).to eq(default_graetzl)
      end

      it 'should not create new record' do
        expect { create(:user, graetzl: build(:graetzl)) }.not_to change { Graetzl.count }
      end
    end
  end

end
