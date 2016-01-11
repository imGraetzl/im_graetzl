require 'rails_helper'

RSpec.feature 'Registration', type: :feature do
  let(:user) { build(:user) }

  before do
    WebMock.allow_net_connect!
    create(:district, zip: '1020')
    visit new_registration_path
  end

  feature 'address matches single graetzl' do
    let!(:graetzl) { create(:naschmarkt) }
    let!(:address) { build(:esterhazygasse) }
    # data for graetzl step
    let!(:district_1) { create(:district) }
    let!(:district_2) { create(:district,
      area: 'POLYGON ((20.0 20.0, 20.0 30.0, 30.0 30.0, 30.0 20.0, 20.0 20.0))')
    }
    let!(:graetzl_1) { create(:graetzl) }
    let!(:graetzl_2) { create(:graetzl,
      area: 'POLYGON ((25.0 25.0, 25.0 26.0, 27.0 27.0, 25.0 25.0))')
    }

    scenario 'user registers in suggested graetzl', js: true do
      fill_in_address(address)
      click_button 'Weiter'

      expect(page).to have_text("Willkommen im Grätzl #{graetzl.name}")

      fill_in_user_form(user)
      click_button 'Jetzt registrieren'

      expect(page).to have_content("Super, du bist nun registriert! Damit wir deine Anmeldung abschließen können, müsstest du bitte noch deinen Account bestätigen. Klicke dazu auf den Link, den wir dir soeben per E-Mail zugeschickt haben.")

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(user.email)
      expect(email.subject).to eq('Bitte aktiviere deinen Account')
      expect(email.body.encoded).to match("willkommen im Grätzl #{graetzl.name}!")
    end

    scenario 'user changes graetzl manually', js: true do
      fill_in_address(address)
      click_button 'Weiter'

      expect(page).to have_text("Willkommen im Grätzl #{graetzl.name}")

      click_link 'Nicht dein Grätzl?'

      expect(page).to have_text('Wähle dein Heimatgrätzl')
      expect(page).to have_text('Bitte wähle dein Grätzl manuell.')

      select "#{district_2.zip}", from: :district_id
      sleep 2
      select "#{graetzl_2.name}", from: :graetzl_id
      click_button 'Weiter'

      expect(page).to have_text("Willkommen im Grätzl #{graetzl_2.name}")

      fill_in_user_form(user)
      click_button 'Jetzt registrieren'

      expect(page).to have_content("Super, du bist nun registriert! Damit wir deine Anmeldung abschließen können, müsstest du bitte noch deinen Account bestätigen. Klicke dazu auf den Link, den wir dir soeben per E-Mail zugeschickt haben.")

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(user.email)
      expect(email.subject).to eq('Bitte aktiviere deinen Account')
      expect(email.body.encoded).to match("willkommen im Grätzl #{graetzl_2.name}!")
    end
  end

  feature 'address matches multiple graetzls' do
    let!(:seestadt_aspern) { create(:seestadt_aspern) }
    let!(:aspern) { create(:aspern) }
    let(:address) { build(:seestadt) }
    let!(:naschmarkt) { create(:naschmarkt) }
    let!(:esterhazygasse) { build(:esterhazygasse) }

    scenario 'user selects graetzl from list', js: true do
      fill_in :address, with: "#{address.street_name}"
      sleep 2
      click_button 'Weiter'

      expect(page).to have_text("Unter #{address.street_name} konnten wir 2 Grätzl finden.")
      expect(page).to have_field('graetzl_id', type: 'radio', count: 2, visible: false)

      find("label[for=graetzl_id_#{seestadt_aspern.id}]").click
      click_button 'Weiter'

      expect(page).to have_text("Willkommen im Grätzl #{seestadt_aspern.name}")

      fill_in_user_form(user)
      click_button 'Jetzt registrieren'

      expect(page).to have_content("Super, du bist nun registriert! Damit wir deine Anmeldung abschließen können, müsstest du bitte noch deinen Account bestätigen. Klicke dazu auf den Link, den wir dir soeben per E-Mail zugeschickt haben.")

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(user.email)
      expect(email.subject).to eq('Bitte aktiviere deinen Account')
      expect(email.body.encoded).to match("willkommen im Grätzl #{seestadt_aspern.name}!")
    end

    scenario 'user uses back back button to enter address again', js: true do
      pending('not implemented yet')
      fail
      # fill_in :address, with: "#{address.street_name}"
      # sleep 2
      # click_button 'Weiter'

      # expect(page).to have_text("Unter #{address.street_name} konnten wir 2 Grätzl finden.")
      # expect(page).to have_field('graetzl', type: 'radio', count: 2, visible: false)

      # click_link 'Zurück'

      # expect(page).to have_text('Lass uns zu Beginn dein Heimatgrätzl finden...')

      # fill_in_address(esterhazygasse)
      # click_button 'Weiter'

      # expect(page).to have_text("Willkommen im Grätzl #{naschmarkt.name}")

      # fill_in_user_data
      # click_button 'Jetzt registrieren'

      # email = ActionMailer::Base.deliveries.last
      # expect(email.to).to include(user.email)
      # expect(email.subject).to eq('Bitte aktiviere deinen Account')
      # expect(email.body.encoded).to match("willkommen im Grätzl #{naschmarkt.name}!")
    end
  end

  feature 'address matches no graetzl' do
    # data for graetzl step
    let!(:district_1) { create(:district) }
    let!(:district_2) { create(:district,
      area: 'POLYGON ((20.0 20.0, 20.0 30.0, 30.0 30.0, 30.0 20.0, 20.0 20.0))')
    }
    let!(:graetzl_1) { create(:graetzl) }
    let!(:graetzl_2) { create(:graetzl,
      area: 'POLYGON ((25.0 25.0, 25.0 26.0, 27.0 27.0, 25.0 25.0))')
    }

    scenario 'enter valid userdata', js: true do
      fill_in :address, with: 'qwertzuiopü'
      sleep 2
      click_button 'Weiter'

      expect(page).to have_text('Unter qwertzuiopü konnten wir leider kein Grätzl finden.')

      select "#{district_2.zip}", from: :district_id
      sleep 2
      select "#{graetzl_2.name}", from: :graetzl_id
      click_button 'Weiter'

      expect(page).to have_text("Willkommen im Grätzl #{graetzl_2.name}")

      fill_in_user_form(user)
      click_button 'Jetzt registrieren'

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(user.email)
      expect(email.subject).to eq('Bitte aktiviere deinen Account')
      expect(email.body.encoded).to match("willkommen im Grätzl #{graetzl_2.name}!")
    end
  end

  private

    def fill_in_address(address)
      fill_in :address, with: "#{address.street_name} #{address.street_number}"
      sleep 2
    end

  def fill_in_user_form(user)
    fill_in :user_username, with: user.username
    fill_in :user_email, with: user.email
    fill_in :user_password, with: 'secret'

    fill_in :user_first_name, with: user.first_name
    fill_in :user_last_name, with: user.last_name

    find('label', text: 'Ich stimme den AGBs zu').click
  end
end
