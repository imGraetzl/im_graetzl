require 'rails_helper'

RSpec.describe LocationOwnership, type: :model do

  # it 'has a valid factory' do
  #   expect(build_stubbed(:location_ownership)).to be_valid
  # end

  # describe 'scope' do
  #   describe ':all_pending' do
  #     let!(:pending_ownership) { create(:location_ownership) }
  #     let!(:requested_ownership) { create(:location_ownership,
  #       state: LocationOwnership.states[:requested]) }
  #     let!(:approved_ownership) { create(:location_ownership,
  #       state: LocationOwnership.states[:approved]) }

  #     it 'includes :pending location_ownerships' do
  #       expect(LocationOwnership.all_pending).to include(pending_ownership)
  #     end

  #     it 'includes :requested location_ownerships' do
  #       expect(LocationOwnership.all_pending).to include(requested_ownership)
  #     end

  #     it 'does not include :approved location_ownerships' do
  #       expect(LocationOwnership.all_pending).not_to include(approved_ownership)
  #     end
  #   end
  # end

  # describe 'assocations' do
  #   let(:location_ownership) { create(:location_ownership) }

  #   it 'has state attribute' do
  #     expect(location_ownership).to respond_to(:state)
  #   end
  # end

  # describe 'state' do
  #   describe ':pending' do
  #     let(:location_ownership) { create(:location_ownership) }

  #     it 'is initial state' do
  #       expect(location_ownership.pending?).to be_truthy
  #     end

  #     context 'when #approve' do
  #       context 'when location :managed' do
  #         before { location_ownership.location.state = Location.states[:managed] }

  #         it 'can be approved' do
  #           expect(location_ownership.may_approve?).to be_truthy
  #         end

  #         it 'changes to :approved' do
  #           expect{
  #             location_ownership.approve
  #           }.to change(location_ownership, :state).to 'approved'
  #         end

  #         it 'notifies user' do
  #           expect(location_ownership).to receive(:notify_user)
  #           location_ownership.approve
  #         end
  #       end

  #       context 'when location not :managed' do
  #         it 'can not be approved' do
  #           expect(location_ownership.may_approve?).to be_falsey
  #           expect{ location_ownership.approve }.to raise_error(AASM::InvalidTransition)
  #         end
  #       end
  #     end
  #   end

  #   describe ':requested' do
  #     let(:location_ownership) { create(:location_ownership, state: LocationOwnership.states[:requested]) }

  #     context 'when #approve' do
  #       context 'when location :managed' do
  #         before { location_ownership.location.state = Location.states[:managed] }

  #         it 'can be approved' do
  #           expect(location_ownership.may_approve?).to be_truthy
  #         end

  #         it 'changes to :approved' do
  #           expect{
  #             location_ownership.approve
  #           }.to change(location_ownership, :state).to 'approved'
  #         end

  #         it 'notifies user' do
  #           expect(location_ownership).to receive(:notify_user)
  #           location_ownership.approve
  #         end
  #       end

  #       context 'when location not :managed' do
  #         it 'can not be approved' do
  #           expect(location_ownership.may_approve?).to be_falsey
  #           expect{ location_ownership.approve }.to raise_error(AASM::InvalidTransition)
  #         end
  #       end
  #     end
  #   end

  #   describe ':approved' do
  #     let(:location_ownership) { create(:location_ownership, state: LocationOwnership.states[:approved]) }

  #     it 'can not be approved again' do
  #       expect(location_ownership.may_approve?).to be_falsey
  #     end
  #   end
  # end
end
