require 'rails_helper'

RSpec.feature 'Registration', type: :feature do
  let!(:district_1) { create(:district) }
  let!(:district_2) { create(:district,
    area: 'POLYGON ((20.0 20.0, 20.0 30.0, 30.0 30.0, 30.0 20.0, 20.0 20.0))')
  }
  let!(:graetzl_1) { create(:graetzl) }
  let!(:graetzl_2) { create(:graetzl,
    area: 'POLYGON ((25.0 25.0, 25.0 26.0, 27.0 27.0, 25.0 25.0))')
  }

  before { visit user_registration_address_path }

  context 'address matches single graetzl' do
    let!(:graetzl) { create(:naschmarkt) }
    let(:address) { build(:esterhazygasse) }

    scenario 'enter valid userdata', js: true do
      fill_in :address, with: "#{address.street_name} #{address.street_number}"
      sleep 2
      click_button 'Weiter'

      expect(page).to have_text("Willkommen im Grätzl #{graetzl.name}")
      expect(page).to have_link('Nicht dein Grätzl?', href: user_registration_graetzl_path)

      fill_in_user_data
      click_button 'Jetzt registrieren'
    end

    scenario 'change graetzl manually', js: true do
      fill_in :address, with: "#{address.street_name} #{address.street_number}"
      sleep 2
      click_button 'Weiter'

      click_link 'Nicht dein Grätzl?'

      select "#{district_2.zip}", from: :district_id
      sleep 2
      select "#{graetzl_2.name}", from: :graetzl
      click_button 'Weiter'

      expect(page).to have_text("Willkommen im Grätzl #{graetzl_2.name}")
      expect(page).to have_link('Nicht dein Grätzl?', href: user_registration_graetzl_path)  

      fill_in_user_data
      click_button 'Jetzt registrieren'
    end
  end

  context 'address matches multiple graetzls' do
    let!(:seestadt_aspern) { create(:seestadt_aspern) }
    let!(:aspern) { create(:aspern) }
    let(:address) { build(:seestadt) }
    let!(:naschmarkt) { create(:naschmarkt) }
    let(:esterhazygasse) { build(:esterhazygasse) }

    scenario 'enter valid userdata', js: true do
      fill_in :address, with: "#{address.street_name}"
      sleep 2
      click_button 'Weiter'

      expect(page).to have_text("Unter #{address.street_name} konnten wir 2 Grätzl finden.")
      expect(page).to have_field('graetzl', type: 'radio', count: 2, visible: false)

      find("label[for=graetzl_#{seestadt_aspern.id}]").click
      click_button 'Weiter'

      expect(page).to have_text("Willkommen im Grätzl #{seestadt_aspern.name}")
      expect(page).to have_link('Nicht dein Grätzl?', href: user_registration_graetzl_path)

      fill_in_user_data
      click_button 'Jetzt registrieren'
    end

    scenario 'use back button to enter address again', js: true do
      fill_in :address, with: "#{address.street_name}"
      sleep 2
      click_button 'Weiter'

      click_link 'Zurück'

      expect(page).to have_text('Lass uns zu Beginn dein Heimatgrätzl finden...')

      fill_in :address, with: "#{esterhazygasse.street_name} #{esterhazygasse.street_number}"
      sleep 2
      click_button 'Weiter'

      expect(page).to have_text("Willkommen im Grätzl #{naschmarkt.name}")
      expect(page).to have_link('Nicht dein Grätzl?', href: user_registration_graetzl_path)

      fill_in_user_data
      click_button 'Jetzt registrieren'
    end
  end

  context 'address matches no graetzl' do

    scenario 'enter valid userdata', js: true do
      fill_in :address, with: 'qwertzuiopü'
      sleep 2
      click_button 'Weiter'

      expect(page).to have_text('Unter qwertzuiopü konnten wir leider kein Grätzl finden.')

      select "#{district_2.zip}", from: :district_id
      sleep 2
      select "#{graetzl_2.name}", from: :graetzl
      click_button 'Weiter'

      expect(page).to have_text("Willkommen im Grätzl #{graetzl_2.name}")
      expect(page).to have_link('Nicht dein Grätzl?', href: user_registration_graetzl_path)  

      fill_in_user_data
      click_button 'Jetzt registrieren' 
    end
  end

  private

    # def fill_in_address(address)
    #   fill_in :address, with: "#{address.street_name} #{address.street_number}"
    #   sleep 2
    # end

    def fill_in_user_data
      fill_in :user_username, with: 'newuser'
      fill_in :user_email, with: 'newuser@example.com'
      fill_in :user_password, with: 'supersecret'

      fill_in :user_first_name, with: 'newuserfirstname'
      fill_in :user_last_name, with: 'newuserlastname'

      find('label', text: 'Ich stimme den AGBs zu').click      
    end
end