require 'rails_helper'

RSpec.describe LocationOwnership, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed(:location_ownership)).to be_valid
  end  

  describe 'assocations' do
    let(:location_ownership) { create(:location_ownership) }
    describe 'state' do

      it 'has state attribute' do
        expect(location_ownership).to respond_to(:state)
      end
    end
  end

  describe 'state' do
    describe ':pending' do
      let(:location_ownership) { create(:location_ownership) }

      it 'is initial state' do
        expect(location_ownership.pending?).to be_truthy
      end

      context 'when location :managed' do
        before { location_ownership.location.state = Location.states[:managed] }

        it 'can be approved' do
          expect(location_ownership.may_approve?).to be_truthy
        end
      end

      context 'when location not :managed' do
        it 'can not be approved' do
          expect(location_ownership.may_approve?).to be_falsey
        end
      end
    end
  end
end
