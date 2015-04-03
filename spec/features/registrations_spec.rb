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

        expect(page).to have_selector("input[name='user[address_attributes][street_name]']", visible: false)
        expect(page).to have_selector("input[name='user[address_attributes][street_number]']", visible: false)
        expect(page).to have_selector("input[name='user[address_attributes][zip]']", visible: false)
        expect(page).to have_selector("input[name='user[address_attributes][city]']", visible: false)
        expect(page).to have_selector("input[name='user[address_attributes][coordinates]']", visible: false)
      end
    end
  end

  describe 'step 2: submit address' do
    let(:esterhazygasse) { build(:esterhazygasse) }
    let(:naschmarkt) { build(:naschmarkt) }

    before do
      fill_in 'address', with: "#{esterhazygasse.street_name} #{esterhazygasse.street_number}"
      click_button('Weiter')
      wait_for_ajax
    end

    it 'injects address_attributes in hidden field', js: true do
      street_name = find("input[name='user[address_attributes][street_name]']", visible: false).value
      street_number = find("input[name='user[address_attributes][street_number]']", visible: false).value
      zip = find("input[name='user[address_attributes][zip]']", visible: false).value
      city = find("input[name='user[address_attributes][city]']", visible: false).value
      coords = find("input[name='user[address_attributes][coordinates]']", visible: false).value

      expect(street_name).to eq(esterhazygasse.street_name)
      expect(street_number).to eq(esterhazygasse.street_number)
      expect(zip).to eq(esterhazygasse.zip)
      expect(city).to eq(esterhazygasse.city)
      expect(coords).to eq(esterhazygasse.coordinates.as_text)
    end
    it 'has hidden field for graetzl_name', js: true do
      graetzl_fields = find('div#user_graetzl_fields', visible: false)
      within graetzl_fields do
        expect(page).to have_selector("input[name='user[graetzl_attributes][name]']", visible: false)
      end
    end
    it 'injects graetzl_name in hidden field', js: true do
      graetzl_name = find("input[name='user[graetzl_attributes][name]']", visible: false).value
      expect(graetzl_name).to eq(naschmarkt.name)
    end
    it 'shows welcome message', js: true do
      fields_description = find('div#user_fields_description')
      within fields_description do
        expect(page).to have_content(naschmarkt.name)
      end
    end
  end
end
