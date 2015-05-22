require 'rails_helper'

RSpec.feature 'Registrations', type: :feature do

  let!(:naschmarkt) { create(:naschmarkt) }
  let!(:seestadt_aspern) { create(:seestadt_aspern) }
  let!(:aspern) { create(:aspern) }

  describe 'register new user' do
    describe 'find graetzl' do
      before { visit user_registration_address_path }
      
      it 'has :address field' do
        expect(page).to have_field(:address)
      end

      it 'has hidden :feature field' do
        expect(page).to have_selector('#feature', visible: false)
      end

      describe 'search address' do
        context 'with single result' do
        let(:esterhazygasse) { build(:esterhazygasse) }

          it 'forwards to details form', js: true do
            fill_in :address, with: "#{esterhazygasse.street_name} #{esterhazygasse.street_number}"
            sleep 2
            click_button 'Weiter ins Grätzl'

            expect(page).to have_text('Willkommen im Grätzl Naschmarkt')
            expect(page).to have_link('Nicht dein Grätzl?', href: user_registration_graetzl_path)
          end
        end

        context 'with multiple results' do
          let(:seestadt) { build(:seestadt) }

          it 'shows options to choose graetzl and forwards to details from', js: true do
            fill_in :address, with: "#{seestadt.street_name}"
            sleep 2
            click_button 'Weiter ins Grätzl'

            expect(page).to have_text("Unter #{seestadt.street_name} konnten wir 2 Grätzl finden.")
            expect(page).to have_field('graetzl', type: 'radio', count: 2, visible: false)

            find("label[for=graetzl_#{seestadt_aspern.id}]").click
            click_button 'Weiter ins Grätzl'

            expect(page).to have_text('Willkommen im Grätzl Seestadt Aspern')
            expect(page).to have_link('Nicht dein Grätzl?', href: user_registration_graetzl_path)
          end
        end

        context 'with no result' do

          it 'lets choose district and graetzl', js: true do
            fill_in :address, with: 'qwertzuiopü'
            sleep 2
            click_button 'Weiter ins Grätzl'

            expect(page).to have_text('Unter qwertzuiopü konnten wir leider kein Grätzl finden.')
            expect(page).to have_selector('select#graetzl')
            expect(page).to have_selector('select#district_id')

            # find("label[for=graetzl_#{seestadt_aspern.id}]").click
            # click_button 'Weiter ins Grätzl'

            # expect(page).to have_text('Unter qwertzuiopü konnten wir leider kein Grätzl finden.')
            # expect(page).to have_link('Nicht dein Grätzl?', href: user_registration_graetzl_path)
          end
        end
      end
    end
  end
end  