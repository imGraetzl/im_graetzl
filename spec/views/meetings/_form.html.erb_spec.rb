require 'rails_helper'

RSpec.describe 'meetings/_form', type: :view do

  # Shared examples
  shared_examples :editable_fields do

    it 'displays editable :address field' do
      expect(rendered).to have_field(:address)
    end

    it 'displays editable :address_description field' do
      expect(rendered).to have_field(:meeting_address_attributes_description)
    end

    it 'has hidden :feature field' do
      expect(rendered).to have_selector('#feature', visible: false)
    end
  end

  shared_examples :readonly_address_fields do

    it 'has readonly :address field' do
      expect(rendered).to have_xpath("//input[@name='address'][@readonly='readonly']")
    end

    it 'has readonly :address_description field' do
      expect(rendered).to have_xpath("//input[@name='meeting[address_attributes][description]'][@readonly='readonly']")
    end

    it 'has hidden :feature field' do
      expect(rendered).to have_selector('#feature', visible: false)
    end
  end

  shared_examples :disabled_location_fields do   

    it 'has hidden :location_id field' do
      expect(rendered).to have_selector('#meeting_location_id', visible: false)
    end

    it 'has no :location checkbox' do
      expect(rendered).not_to have_field(:location)
    end
  end

  # Scenarios
  let(:meeting) { create(:meeting) }

  context 'when normal user' do
    let(:user) { create(:user) }
    before do
      sign_in user
      assign(:meeting, meeting)
    end

    describe 'without disable_fields param' do
      before { render }

      include_examples :editable_fields

      it 'has hidden :location_id field' do
        expect(rendered).to have_selector('#meeting_location_id', visible: false)
      end

      it 'has no :location checkbox' do
        expect(rendered).not_to have_field(:location)
      end
    end

    describe 'with disable_fields param true' do
      before { render 'meetings/form', disable_fields: true }
      include_examples :readonly_address_fields
      include_examples :disabled_location_fields
    end
  end

  context 'when business user' do
    let(:user) { create(:user_business) }
    before do
      sign_in user
      assign(:meeting, meeting)
    end

    describe 'without param' do
      before { render }

      include_examples :editable_fields

      it 'displays :location checkbox' do
        expect(rendered).to have_field(:location)
      end

      it 'has hidden select for :location_id' do
        expect(rendered).to have_selector('#meeting_location_id', visible: false)
      end
    end

    describe 'with disable_fields param true' do
      before { render 'meetings/form', disable_fields: true }
      include_examples :readonly_address_fields
      include_examples :disabled_location_fields
    end
  end
end