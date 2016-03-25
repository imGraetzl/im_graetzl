require 'rails_helper'

RSpec.describe Admin::ZuckerlsController, type: :controller do
  before do
    allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation).and_return true
    ActiveJob::Base.queue_adapter = :test
    sign_in create(:user, :admin)
  end

  describe 'PATCH update' do
    let(:zuckerl) { create :zuckerl }

    describe 'trigger aasm event' do
      let(:event) { 'mark_as_paid' }
      let(:params) {
        { id: zuckerl, zuckerl: { active_admin_requested_event: event } }
      }

      it 'updates aasm_state' do
        expect{
          patch :update, params
          zuckerl.reload
        }.to change{zuckerl.aasm_state}.from('pending').to('paid')
      end

      it 'enqueues InvoiceJob' do
        expect{
          patch :update, params
        }.to have_enqueued_job(Zuckerl::InvoiceJob)
      end
    end
  end
end
