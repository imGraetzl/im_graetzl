require 'rails_helper'

RSpec.describe Admin::ZuckerlsController, type: :controller do
  before { sign_in create(:admin) }

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
    end
  end
end
