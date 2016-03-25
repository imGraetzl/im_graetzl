require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Activity, type: :model do
  subject(:ability){ Ability.new(user) }

  describe 'for locations' do
    context 'when admin' do
      let(:user) { create :user, :admin }

      it 'is able to manage locations' do
        expect(ability).to be_able_to :manage, Location
      end
    end
    context 'when guest' do
      let(:user) { build :user }

      it 'can read locations' do
        expect(ability).to be_able_to :read, Location
      end

      it 'cannot crud' do
        expect(ability).not_to be_able_to :crud, Location.new
      end
    end
    context 'when persisted user' do
      let!(:user) { create :user }
      let(:location) { create :location }

      it 'can read locations' do
        expect(ability).to be_able_to :read, location
      end

      it 'can create locations' do
        expect(ability).to be_able_to :create, Location
      end

      it 'can crud own locations' do
        create :location_ownership, location: location, user: user
        expect(ability).to be_able_to :crud, location
      end

      it 'cannot crud other locations' do
        create :location_ownership, location: location, user: create(:user)
        expect(ability).not_to be_able_to :crud, location
      end
    end
  end
end
