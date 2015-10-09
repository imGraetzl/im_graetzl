require 'rails_helper'

RSpec.describe 'meetings/_form', type: :view do

  describe 'editable fields' do
    let(:meeting) { create(:meeting) }
    before do
      sign_in create(:user)
      assign(:meeting, meeting)
    end

    context 'without disable_fields param' do
      before { render }

      it 'displays editable :address field' do
        expect(rendered).to have_field(:address)
      end

      it 'displays editable :address_description field' do
        expect(rendered).to have_field(:meeting_address_attributes_description)
      end

      it 'displays hidden :feature field' do
        expect(rendered).to have_selector('#feature', visible: false)
      end

      it 'displays :location checkbox' do
        expect(rendered).to have_field(:location)
      end

      it 'displays hidden select for :location_id' do
        expect(rendered).to have_selector('#meeting_location_id', visible: false)
      end
    end

    context 'with disable_fields param' do
      before { render 'meetings/form', disable_fields: true }

      it 'has readonly :address field' do
        expect(rendered).to have_xpath("//input[@name='address'][@readonly='readonly']")
      end

      it 'has readonly :address_description field' do
        expect(rendered).to have_xpath("//input[@name='meeting[address_attributes][description]'][@readonly='readonly']")
      end

      it 'has hidden :feature field' do
        expect(rendered).to have_selector('#feature', visible: false)
      end  

      it 'has hidden :location_id field' do
        expect(rendered).to have_selector('#meeting_location_id', visible: false)
      end

      it 'has no :location checkbox' do
        expect(rendered).not_to have_field(:location)
      end
    end
  end
end