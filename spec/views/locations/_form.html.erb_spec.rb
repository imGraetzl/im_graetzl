require 'rails_helper'

RSpec.describe 'locations/_form', type: :view do
  let(:graetzl) { create(:graetzl) }
  let(:location) { build(:location, graetzl: graetzl) }

  before do
    assign(:location, location)
    assign(:graetzl, graetzl)
    render
  end

  describe 'basic info' do    

    it 'has subheadline' do
      expect(rendered).to have_text('Basic Info')
    end

    it 'has field for :name' do
      expect(rendered).to have_field(:location_name)
    end

    it 'has field for :slogan' do
      expect(rendered).to have_field(:location_slogan)
    end

    it 'has field for :description' do
      expect(rendered).to have_field(:location_description)
    end

    it 'has field for :cover_photo' do
      expect(rendered).to have_field(:location_cover_photo)
    end

    it 'has field for :avatar' do
      expect(rendered).to have_field(:location_avatar)
    end
  end

  describe 'contact info' do    

    it 'has subheadline' do
      expect(rendered).to have_text('Kontakt')
    end

    it 'has field for :contact_website' do
      expect(rendered).to have_field(:location_contact_attributes_website)
    end

    it 'has field for :contact_email' do
      expect(rendered).to have_field(:location_contact_attributes_email)
    end

    it 'has field for :contact_phone' do
      expect(rendered).to have_field(:location_contact_attributes_phone)
    end
  end  

  describe 'address info' do    

    it 'has subheadline' do
      expect(rendered).to have_text('Adresse')
    end

    it 'has field for :address_street_name' do
      expect(rendered).to have_field(:location_address_attributes_street_name)
    end

    it 'has field for :address_street_number' do
      expect(rendered).to have_field(:location_address_attributes_street_number)
    end

    it 'has field for :address_zip' do
      expect(rendered).to have_field(:location_address_attributes_zip)
    end

    it 'has field for :address_city' do
      expect(rendered).to have_field(:location_address_attributes_city)
    end

    it 'has hidden field for :address_coordinates' do
      expect(rendered).to have_selector('#location_address_attributes_coordinates', visible: false)
    end
  end
end