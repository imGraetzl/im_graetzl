require 'rails_helper'

RSpec.describe ZuckerlPublisher do

  describe 'monthly_zuckerl_update' do
    before do
      allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation)
      allow_any_instance_of(Zuckerl).to receive(:send_live_information)
    end

    let(:last_month) { Date.today.last_month }
    let!(:pending_zuckerl) { create :zuckerl, :pending, created_at: last_month.beginning_of_month+1.day }
    let!(:draft_zuckerl) { create :zuckerl, :draft, created_at: last_month.beginning_of_month+2.days }
    let!(:paid_zuckerl) { create :zuckerl, :paid, created_at: last_month.beginning_of_month+2.days }
    let!(:this_month) { create :zuckerl, :paid }
    let!(:live_zuckerl) { create :zuckerl, :live, created_at: last_month.beginning_of_month-2.days }

    let(:service) { ZuckerlPublisher.new }

    it 'updates all from last_month to live' do
      service.publish_drafted(last_month.beginning_of_month..last_month.end_of_month)
      expect(Zuckerl.live).to include(pending_zuckerl, draft_zuckerl, paid_zuckerl)
    end

    it 'does not update new ones' do
      service.publish_drafted(last_month.beginning_of_month..last_month.end_of_month)
      expect(Zuckerl.live).not_to include(this_month)
    end

    it 'expires live ones' do
      expect{
        service.expire_published
        live_zuckerl.reload
      }.to change{live_zuckerl.aasm_state}.to 'expired'
    end
  end
end
