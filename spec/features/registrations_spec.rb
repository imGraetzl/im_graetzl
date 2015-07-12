require 'rails_helper'

RSpec.feature 'Registration', type: :feature do

  before { visit user_registration_address_path }

  scenario 'address matches only one graetzl', js: true do
    create(:naschmarkt)
    address = build(:esterhazygasse)

    fill_in :address, with: "#{address.street_name} #{address.street_number}"
    sleep 2
    click_button 'Weiter'

    expect(page).to have_text('Willkommen im Grätzl Naschmarkt')
    expect(page).to have_link('Nicht dein Grätzl?', href: user_registration_graetzl_path)

    fill_in_user_data
    click_button 'Jetzt registrieren'
  end

  scenario 'address matches multiple graetzl', js: true do
    seestadt_aspern = create(:seestadt_aspern)
    create(:aspern)
    address = build(:seestadt)

    fill_in :address, with: "#{address.street_name}"
    sleep 2
    click_button 'Weiter'

    expect(page).to have_text("Unter #{address.street_name} konnten wir 2 Grätzl finden.")
    expect(page).to have_field('graetzl', type: 'radio', count: 2, visible: false)

    find("label[for=graetzl_#{seestadt_aspern.id}]").click
    click_button 'Weiter'

    expect(page).to have_text('Willkommen im Grätzl Seestadt Aspern')
    expect(page).to have_link('Nicht dein Grätzl?', href: user_registration_graetzl_path)

    fill_in_user_data
    click_button 'Jetzt registrieren'
  end

  scenario 'address matches no graetzl', js: true do
    district_1 = create(:district)
    district_2 = create(:district,
      area: 'POLYGON ((20.0 20.0, 20.0 30.0, 30.0 30.0, 30.0 20.0, 20.0 20.0))')
    graetzl_1 = create(:graetzl)
    graetzl_2 = create(:graetzl,
      area: 'POLYGON ((25.0 25.0, 25.0 26.0, 27.0 27.0, 25.0 25.0))')

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

  private

    def fill_in_user_data
      fill_in :user_username, with: 'newuser'
      fill_in :user_email, with: 'newuser@example.com'
      fill_in :user_password, with: 'supersecret'

      fill_in :user_first_name, with: 'newuserfirstname'
      fill_in :user_last_name, with: 'newuserlastname'

      find('label', text: 'Ich stimme den AGBs zu').click      
    end
end