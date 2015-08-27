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

    it 'has :feature field' do
      expect(rendered).to have_selector('#feature', visible: false)
    end
  end

  shared_examples :disabled_fields do

    it 'has disabled :address field' do
      expect(rendered).to have_field(:address, disabled: true)
    end

    it 'has disabled :address_description field' do
      expect(rendered).to have_field(:meeting_address_attributes_description, disabled: true)
    end

    it 'has :feature field' do
      expect(rendered).to have_selector('#feature', visible: false)
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

    describe 'without param' do
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

      include_examples :disabled_fields

      it 'has hidden :location_id field' do
        expect(rendered).to have_selector('#meeting_location_id', visible: false)
      end

      it 'has no :location checkbox' do
        expect(rendered).not_to have_field(:location)
      end
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

      it 'displays hidden select for :location_id' do
        expect(rendered).to have_selector('#meeting_location_id', visible: false)
      end
    end

    describe 'with disable_fields param true' do
      before { render 'meetings/form', disable_fields: true }

      include_examples :disabled_fields      

      it 'has disabled :location checkbox' do
        expect(rendered).to have_field(:location, disabled: true)
      end

      it 'has hidden select for :location_id' do
        expect(rendered).to have_selector('#meeting_location_id', visible: false)
      end
    end
  end
end