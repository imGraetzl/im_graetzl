require 'rails_helper'

RSpec.feature "Registrations", type: :feature do
  before { visit new_user_registration_path }

  describe 'step 1: show address form' do
    it 'has address form' do      
      expect(page).to have_selector("form[action='/addresses/fetch_graetzl'][method='post']")
    end
    it 'has address field and submit button' do
      address_form = find("form[action='/addresses/fetch_graetzl'][method='post']")
      within address_form do
        expect(page).to have_field('address')
        expect(page).to have_selector("input[name='commit'][type='submit']")
      end
    end
    it 'has hidden field for address_attributes' do
      expect(page).to have_selector('div#user_address_attributes')
    end
    it 'has hidden inputs for address_attributes values' do
      address_fields = find('div#user_address_attributes')
      within address_fields do
        expect(page).to have_selector('input#user_address_attributes_street_name', visible: false)
        expect(page).to have_selector('input#user_address_attributes_street_number', visible: false)
        expect(page).to have_selector('input#user_address_attributes_zip', visible: false)
        expect(page).to have_selector('input#user_address_attributes_city', visible: false)
        expect(page).to have_selector('input#user_address_attributes_coordinates', visible: false)
      end
    end
  end

  describe 'step 2: submit address' do
    let(:address) { build(:esterhazygasse) }
    it 'injects address values in hidden field', js: true do
      fill_in 'address', with: "#{address.street_name} #{address.street_number}"
      click_button('Weiter')
      wait_for_ajax


      #DatabaseCleaner.clean
      #page.execute_script("$('#user_address_attributes_street_name').show()")
      click_button('Weiter')
      
      #el = find("input[name='user[address_attributes][street_name]']", visible: false)
      el = find("input[name='user[address_attributes][street_name]']", visible: false)
      expect(el.value).to eq(address.street_name)
    end
  end
end
