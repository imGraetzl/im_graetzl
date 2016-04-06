require 'rails_helper'

RSpec.describe Admin::ZuckerlsController, type: :controller do
  before do
    allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation).and_return true
    ActiveJob::Base.queue_adapter = :test
    sign_in create(:user, :admin)
  end

  describe 'POST create' do
    let(:location) { create :location }
    let(:params) {{  zuckerl: {
        title: 'some', description: 'some more',
        location_id: location.id,
        aasm_state: 'draft' }}}

    it 'creates new zuckerl record' do
      expect{
        post :create, params
      }.to change{Zuckerl.count}.by 1
    end

    it 'does not enqueue InvoiceJob' do
      expect{
        post :create, params
      }.not_to have_enqueued_job(Zuckerl::InvoiceJob)
    end

    it 'assigns @zuckerl' do
      post :create, params
      expect(assigns :zuckerl).to have_attributes(
        aasm_state: 'draft',
        location: location)
    end
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
