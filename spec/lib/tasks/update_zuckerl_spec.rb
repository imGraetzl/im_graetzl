require 'rails_helper'
require 'rake'

RSpec.describe 'Tasks' do

  describe 'update_zuckerl' do
    before do
      Rake.application.rake_require 'tasks/update_zuckerl'
      Rake::Task.define_task(:environment)
      allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation)
      allow_any_instance_of(Zuckerl).to receive(:send_live_information)
    end

    subject(:task) { Rake::Task['update_zuckerl'] }

    before(:example) { task.reenable }

    let!(:pending_zuckerl) { create :zuckerl, :pending, created_at: Date.today.last_month.beginning_of_month+1.day }
    let!(:draft_zuckerl) { create :zuckerl, :draft, created_at: Date.today.last_month.beginning_of_month+2.days }
    let!(:paid_zuckerl) { create :zuckerl, :paid, created_at: Date.today.last_month.beginning_of_month+2.days }
    let!(:this_month) { create :zuckerl, :paid }
    let!(:live_zuckerl) { create :zuckerl, :live, created_at: Date.today.last_month.beginning_of_month-2.days }

    it 'updates all from last_month to live' do
      task.invoke
      expect(Zuckerl.live).to match_array [pending_zuckerl, draft_zuckerl, paid_zuckerl]
    end

    it 'does not update new ones' do
      task.invoke
      expect(Zuckerl.live).not_to include [this_month]
    end

    it 'expires live ones' do
      expect{
        task.invoke
        live_zuckerl.reload
      }.to change{live_zuckerl.aasm_state}.to 'expired'
    end
  end
end
