require 'rails_helper'

RSpec.describe Zuckerl, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed :zuckerl).to be_valid
  end

  describe '#aasm' do
    let(:zuckerl) { create :zuckerl }

    describe ':pending' do
      it 'is the initial state' do
        expect(zuckerl).to be_pending
      end

      it 'can transition to :paid, :live, :cancelled' do
        expect(zuckerl).to transition_from(:pending).to(:paid).on_event(:mark_as_paid)
        expect(zuckerl).to transition_from(:pending).to(:live).on_event(:put_live)
        expect(zuckerl).to transition_from(:pending).to(:cancelled).on_event(:cancel)
      end

      it 'cannot expire' do
        expect(zuckerl).not_to allow_event :expire
      end
    end

    describe ':paid' do
      before do
        zuckerl.update_attribute(:aasm_state, 'paid')
        zuckerl.update_attribute(:paid_at, Time.now)
      end

      it 'can transition to :live, :cancelled' do
        expect(zuckerl).to transition_from(:paid).to(:live).on_event(:put_live)
        expect(zuckerl).to transition_from(:paid).to(:cancelled).on_event(:cancel)
      end

      it 'cannot be marked as paid' do
        expect(zuckerl).not_to allow_event :mark_as_paid
      end

      it 'cannot expire' do
        expect(zuckerl).not_to allow_event :expire
      end
    end

    describe ':live' do
      before { zuckerl.update_attribute(:aasm_state, 'live') }

      it 'can transition to :cancelled' do
        expect(zuckerl).to transition_from(:live).to(:cancelled).on_event(:cancel)
      end

      it 'can expire' do
        expect(zuckerl).to allow_event :expire
      end

      context 'if already paid' do
        before { zuckerl.update_attribute(:paid_at, Time.now) }

        it 'cannot be marked as paid' do
          expect(zuckerl).not_to allow_event :mark_as_paid
        end

        it 'changes to paid on expire' do
          expect(zuckerl).to transition_from(:live).to(:paid).on_event(:expire)
        end
      end

      context 'if not paid' do
        it 'can be marked as paid' do
          expect(zuckerl).to allow_event :mark_as_paid
        end

        it 'changes to pending on expire' do
          expect(zuckerl).to transition_from(:live).to(:pending).on_event(:expire)
        end
      end
    end

    describe ':cancelled' do
      before { zuckerl.update_attribute(:aasm_state, 'cancelled') }

      it 'cannot transition to any other state' do
        states = zuckerl.aasm.states(permitted: true).map(&:name)
        events = zuckerl.aasm.events(permitted: true).map(&:name)
        expect(states).to contain_exactly :cancelled
        expect(events).to contain_exactly :cancel
      end
    end
  end
end
