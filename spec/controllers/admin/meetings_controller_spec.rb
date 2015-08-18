require 'rails_helper'

RSpec.describe Admin::MeetingsController, type: :controller do
  let(:admin) { create(:user_admin) }

  before { sign_in admin }

  describe 'PUT update' do
    let(:meeting) { create(:meeting) }
    let(:params) {
      {
        id: meeting,
        meeting: meeting.attributes
      }
    }

    it 'changes graetzl' do
      params[:meeting].merge!({ graetzl_id: create(:graetzl).id })
      expect{
        put :update, params
      }.to change{meeting.reload.graetzl}
    end      

    it 'changes name and description' do
      params[:meeting].merge!({ name: 'new name', description: 'new description' })
      put :update, params
      meeting.reload
      expect(meeting.name).to eq 'new name'
      expect(meeting.description).to eq 'new description'
    end

    describe 'location' do
      let(:location) { create(:location) }

      it 'adds location' do
        params[:meeting].merge!({ location_id: location.id })
        expect{
          put :update, params
        }.to change{meeting.reload.location}.to location
      end

      it 'removes location' do
        params[:meeting].merge!({ location_id: '' })
        meeting.update(location_id: location.id)
        expect{
          put :update, params
        }.to change{meeting.reload.location}.from(location).to nil
      end
    end

    describe 'time' do
      it 'changes start time and date' do
        params[:meeting].merge!({ starts_at_date: Date.tomorrow,
                                  starts_at_time: '18:00' })
        put :update, params
        meeting.reload
        expect(meeting.starts_at_date).to eq Date.tomorrow
        expect(meeting.starts_at_time.strftime('%H:%M')).to eq '18:00'
      end

      it 'removes starts_at_date' do
        params[:meeting].merge!({ starts_at_date: '' })
        meeting.update(starts_at_date: Date.tomorrow)
        expect{
          put :update, params
        }.to change{meeting.reload.starts_at_date}.from(Date.tomorrow).to nil
      end

      it 'removes starts_at_time' do
        params[:meeting].merge!({ starts_at_time: '' })
        meeting.update(starts_at_time: '18:00')
        expect{
          put :update, params
        }.to change{meeting.reload.starts_at_time}.to nil
      end

      it 'changes end time and date' do
        params[:meeting].merge!({ ends_at_date: Date.tomorrow,
                                  ends_at_time: '18:00' })
        put :update, params
        meeting.reload
        expect(meeting.ends_at_date).to eq Date.tomorrow
        expect(meeting.ends_at_time.strftime('%H:%M')).to eq '18:00'
      end

      it 'removes ends_at_date' do
        params[:meeting].merge!({ ends_at_date: '' })
        meeting.update(ends_at_date: Date.tomorrow)
        expect{
          put :update, params
        }.to change{meeting.reload.ends_at_date}.from(Date.tomorrow).to nil
      end

      it 'removes ends_at_time' do
        params[:meeting].merge!({ ends_at_time: '' })
        meeting.update(ends_at_time: '18:00')
        expect{
          put :update, params
        }.to change{meeting.reload.ends_at_time}.to nil
      end
    end

    describe 'address' do
      let(:new_address) { create(:address) }

      before do
        params[:meeting].merge!({ address_attributes: new_address.attributes.except('id') })
        put :update, params
        meeting.reload
      end

      it 'does not change address id' do
        expect(meeting.address.id).not_to eq new_address.id
      end

      it 'changes attributes' do
        expect(meeting.address).to have_attributes(
          street_name: new_address.street_name,
          street_number: new_address.street_number,
          zip: new_address.zip,
          city: new_address.city,
          coordinates: new_address.coordinates)
      end
    end

    describe 'going_tos' do
      let!(:new_user) { create(:user) }

      context 'add user' do
        before do
          params[:meeting].merge!({ going_tos_attributes: {'0' => { user_id: new_user.id }}})
        end

        it 'creates new going_to record' do
          expect{
            put :update, params
          }.to change(GoingTo, :count).by(1)
        end

        it 'adds user to meeting' do
          put :update, params
          meeting.reload
          expect(meeting.users).to include(new_user)
        end
      end

      context 'remove user' do
        let!(:going_to) { create(:going_to, user: new_user, meeting: meeting) }

        before do
          params[:meeting].merge!({ going_tos_attributes:
            { '0' => { id: going_to.id, user_id: new_user.id, _destroy: 1 } } })
        end

        it 'deletes going_to record' do
          expect{
            put :update, params
          }.to change(GoingTo, :count).by(-1)
        end

        it 'removes user from meeting' do
          expect(meeting.users). to include(new_user)
          put :update, params
          expect(meeting.reload.users).not_to include(new_user)
        end
      end
    end
  end
end