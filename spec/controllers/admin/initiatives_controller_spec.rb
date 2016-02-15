require 'rails_helper'

RSpec.describe Admin::InitiativesController, type: :controller do
  before do
    allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation).and_return true
    ActiveJob::Base.queue_adapter = :test
    sign_in create(:admin)
  end

  describe 'PATCH update' do
    let(:initiative) { create :initiative }
    let(:graetzls) { create_list :graetzl, 3 }

    describe 'add graetzl associations' do
      let(:params) {
        { id: initiative, initiative: { graetzl_ids: graetzls.map(&:id) } }
      }

      it 'creates operating_range records' do
        expect{
          patch :update, params
        }.to change(OperatingRange, :count).by 3
      end

      it 'associates graetzls' do
        expect(initiative.graetzls).to be_empty
        patch :update, params
        initiative.reload
        expect(initiative.graetzl_ids).to match_array graetzls.map(&:id)
      end
    end

    describe 'change graetzl associations' do
      before do
        initiative.graetzls << graetzls
        initiative.save
      end
      let(:params) {
        { id: initiative, initiative: { graetzl_ids: [graetzls.first.id] } }
      }

      it 'destroys operating_range records' do
        expect{
          patch :update, params
        }.to change(OperatingRange, :count).from(3).to(1)
      end

      it 'removes associated graetzls' do
        expect(initiative.graetzl_ids).to match_array graetzls.map(&:id)
        patch :update, params
        initiative.reload
        expect(initiative.graetzl_ids).to contain_exactly graetzls.first.id
      end
    end
  end
end
