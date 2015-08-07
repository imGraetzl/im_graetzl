require 'rails_helper'

RSpec.describe 'admin/locations/new_from_address', type: :view do
  let(:graetzl) { create(:graetzl) }
  let(:address) { build_stubbed(:address, description: 'something') }
  let(:new_location) { build(:location_basic,
    name: address.description,
    address: address,
    graetzl: graetzl) }

  before do
    assign(:location, new_location)
    render
  end

  describe 'basic info' do

    it 'has field :name with address.description' do
      expect(rendered).to have_field('location[name]', with: address.description)
    end

    it 'has select :graetzl_id with graetzl' do
      expect(rendered).to have_select('location[graetzl_id]', selected: graetzl.name)
    end

    it 'has select :state with state basic' do
      expect(rendered).to have_select('location[state]', selected: 'basic')
    end
  end

  describe 'address' do

    it 'has field [address_attributes][street_name] with address.street_name' do
      expect(rendered).to have_field('location[address_attributes][street_name]', with: address.street_name)
    end

    it 'has field [address_attributes][street_number] with address.street_number' do
      expect(rendered).to have_field('location[address_attributes][street_number]', with: address.street_number)
    end

    it 'has field [address_attributes][zip] with address.zip' do
      expect(rendered).to have_field('location[address_attributes][zip]', with: address.zip)
    end

    it 'has hidden field [address_attributes][coordinates] with address.coordinates' do
      expect(rendered).to have_selector('#location_address_attributes_coordinates', visible: false)
      have_selector("input#location_address_attributes_coordinates[value=\"#{address.coordinates.as_text}\"]")
    end
  end
end