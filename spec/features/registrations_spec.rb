require 'rails_helper'

RSpec.feature "Registrations", type: :feature do

  before do
    @naschmarkt = create(:naschmarkt)
    @seestadt_aspern = create(:seestadt_aspern)
    @aspern = create(:aspern)
    5.times { create(:graetzl) }
    visit addresses_registration_path
  end

  describe 'step 1: address' do
    it 'has address and feature fields' do
      expect(page).to have_field(:address)
      expect(page).to have_selector('#feature', visible: false)
    end

    context 'with single graetzl resutlt' do
      let(:esterhazygasse) { build(:esterhazygasse) }

      it 'redirects to new_user_registration', js: true do
        fill_in :address, with: "#{esterhazygasse.street_name} #{esterhazygasse.street_number}"
        sleep 1
        click_button 'Weiter'

        expect(page).to have_text('Willkommen im Naschmarkt')
      end
    end

    context 'with two results' do
      let(:seestadt) { build(:seestadt) }

      it 'shows options to choose graetzl', js: true do
        fill_in :address, with: "#{seestadt.street_name}"
        sleep 1
        click_button 'Weiter'

        expect(page).to have_text("Unter #{seestadt.street_name} konnten wir 2 Grätzl finden.")
        expect(page).to have_field('graetzl', type: 'radio', count: 2, visible: false)
      end
    end

    context 'with no result' do
      it 'lets user choose from all graetzls' do
        fill_in :address, with: 'qwertzuiopü'
        sleep 1
        click_button 'Weiter'

        expect(page).to have_text('Bitte wähle dein Grätzl manuell.')
        expect(page).to have_selector('select#graetzl')
      end
    end
  end
end