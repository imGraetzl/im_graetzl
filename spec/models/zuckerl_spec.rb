require 'rails_helper'

RSpec.describe Zuckerl, type: :model do

  it 'has a valid factory' do
    expect(build_stubbed :zuckerl).to be_valid
  end

  describe 'attributes' do
    let(:zuckerl) { build_stubbed :zuckerl }

    it 'has virtual attribute for admin event request' do
      expect(zuckerl).to respond_to :active_admin_requested_event
    end
  end

  describe 'associations' do
    before { allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation) }
    let(:zuckerl) { create :zuckerl }

    it 'has location' do
      expect(zuckerl).to respond_to :location
    end

    it 'has initiative' do
      expect(zuckerl).to respond_to :initiative
    end
  end

  describe '#aasm' do
    before do
      allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation).and_return true
      ActiveJob::Base.queue_adapter = :test
    end
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

      it 'triggers LiveInformationJob on put_live' do
        expect{
          zuckerl.put_live!
        }.to have_enqueued_job(Zuckerl::LiveInformationJob)
      end

      it 'triggers InvoiceJob on mark_as_paid' do
        expect{
          zuckerl.mark_as_paid!
        }.to have_enqueued_job(Zuckerl::InvoiceJob)
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

  describe '#payment_reference' do
    it "is a pending example"
  end

  describe 'callbacks' do
    describe 'after_create' do
      it 'calls BookingConfirmationJob' do
        ActiveJob::Base.queue_adapter = :test
        expect{
          create :zuckerl
        }.to have_enqueued_job(Zuckerl::BookingConfirmationJob)
      end

      it 'calls AdminMailer' do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(AdminMailer).to receive(:new_zuckerl).and_return(message_delivery)
        expect(message_delivery).to receive(:deliver_later)
        create :zuckerl
      end
    end
  end
end
