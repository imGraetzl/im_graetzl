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
        #expect(address_form).to have_selector("input[name='commit'][type='submit'][value='Weiter']")
        expect(page).to have_selector("input[name='commit'][type='submit']")
      end
    end
  end

  describe 'step 2: submit address' do
    let(:address) { build(:esterhazygasse) }
    it 'injects address values in hidden fields', js: true do
      DatabaseCleaner.clean
      fill_in 'address', with: "#{address.street_name} #{address.street_number}"
      click_button 'Weiter'

      expect(page).to have_selector("input[name='user[address_attributes][street_name]'][type='hidden'][value='#{address.street_name}']")
    end
  end
end
