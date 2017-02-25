require 'rails_helper'

RSpec.describe Admin::ZuckerlsController, type: :controller do
  before do
    allow_any_instance_of(Zuckerl).to receive(:send_booking_confirmation).and_return true
    ActiveJob::Base.queue_adapter = :test
    sign_in create(:user, :admin)
  end

  describe 'GET index' do
    let!(:zuckerls) { create_list :zuckerl, 30 }
    before { get :index }

    it 'assigns first 30 zuckerls' do
      expect(assigns :zuckerls).to match_array zuckerls
    end

    it 'renders index' do
      expect(response).to render_template 'admin/zuckerls/_index'
    end
  end
  describe 'GET show' do
    let(:zuckerl) { create :zuckerl }
    before { get :show, params: { id: zuckerl } }

    it 'assigns @zuckerl' do
      expect(assigns :zuckerl).to eq zuckerl
    end

    it 'renders show' do
      expect(response).to render_template 'admin/zuckerls/_show'
    end
  end
  describe 'GET new' do
    before { get :new }

    it 'assigns @zuckerl' do
      expect(assigns :zuckerl).to be_a_new Zuckerl
    end

    it 'renders form' do
      expect(response).to render_template 'admin/zuckerls/_form'
    end
  end
  describe 'POST create' do
    let(:location) { create :location }
    let(:params) {{  zuckerl: {
        title: 'some', description: 'some more',
        location_id: location.id,
        aasm_state: 'draft' }}}

    it 'creates new zuckerl record' do
      expect{
        post :create, params: params
      }.to change{Zuckerl.count}.by 1
    end

    it 'does not enqueue InvoiceJob' do
      expect{
        post :create, params: params
      }.not_to have_enqueued_job(Zuckerl::InvoiceJob)
    end

    it 'assigns @zuckerl' do
      post :create, params: params
      expect(assigns :zuckerl).to have_attributes(
        aasm_state: 'draft',
        location: location)
    end
  end
  describe 'GET edit' do
    let(:zuckerl) { create :zuckerl }
    before { get :edit, params: { id: zuckerl } }

    it 'assigns @zuckerl' do
      expect(assigns :zuckerl).to eq zuckerl
    end

    it 'renders form' do
      expect(response).to render_template 'admin/zuckerls/_form'
    end
  end
  describe 'PUT update' do
    let(:zuckerl) { create :zuckerl }

    context 'trigger aasm event' do
      let(:event) { 'mark_as_paid' }
      let(:params) {
        { id: zuckerl, zuckerl: { active_admin_requested_event: event } }
      }

      it 'updates aasm_state' do
        expect{
          put :update, params: params
          zuckerl.reload
        }.to change{zuckerl.aasm_state}.from('pending').to('paid')
      end

      it 'enqueues InvoiceJob' do
        expect{
          put :update, params: params
        }.to have_enqueued_job(Zuckerl::InvoiceJob)
      end
    end
    context 'not trigger aasm event' do
      let!(:location) { create :location }
      let(:params) { { id: zuckerl, zuckerl: { title: 'new title', location_id: location.id } } }

      it 'does not change state' do
        expect{
          put :update, params: params
          zuckerl.reload
        }.not_to change{zuckerl.aasm_state}
      end

      it 'updates attributes' do
        put :update, params: params
        zuckerl.reload
        expect(zuckerl).to have_attributes(title: 'new title', location: location)
      end
    end
  end
  describe 'DELETE destroy' do
    let!(:zuckerl) { create :zuckerl }

    it 'deletes zuckerl record' do
      expect{
        delete :destroy, params: { id: zuckerl }
      }.to change{Zuckerl.count}.by -1
    end
  end
end
