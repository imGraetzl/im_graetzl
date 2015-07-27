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

      it 'has inital state :pending' do
        expect(location_ownership.pending?).to be_truthy
      end
    end
  end
end
