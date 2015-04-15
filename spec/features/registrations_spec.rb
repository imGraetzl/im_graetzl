require 'rails_helper'

RSpec.feature "Registrations", type: :feature do

  before { visit addresses_registration_path }

  describe 'step 1: address' do
    it 'has address field' do
      expect(page).to have_field(:address)
      expect(page).to have_text('Lass uns zu Beginn dein Heimatgrätzl finden...')
    end

    describe 'submit address' do
      before do
        @naschmarkt = create(:naschmarkt)
        @seestadt_aspern = create(:seestadt_aspern)
        @aspern = create(:aspern)
        2.times { create(:graetzl) }
      end

      context 'with single result' do
        let(:esterhazygasse) { build(:esterhazygasse) }

        before do
          fill_in :address, with: "#{esterhazygasse.street_name} #{esterhazygasse.street_number}"
          click_button('Weiter')
        end

        it 'redirects to new_user_registration' do
          expect(page).to have_text('Willkommen im Naschmarkt')
        end

        it 'injects session values in hidden form' do          
          street_name = find('#user_address_attributes_street_name', visible: false).value
          street_number = find('#user_address_attributes_street_number', visible: false).value
          zip = find('#user_address_attributes_zip', visible: false).value
          city = find('#user_address_attributes_city', visible: false).value
          coords = find('#user_address_attributes_coordinates', visible: false).value
          graetzl_name = find('#user_graetzl_attributes_name', visible: false).value

          expect(street_name).to eq(esterhazygasse.street_name)
          expect(street_number).to eq(esterhazygasse.street_number)
          expect(zip).to eq(esterhazygasse.zip)
          expect(city).to eq(esterhazygasse.city)
          expect(coords).to eq(esterhazygasse.coordinates.as_text)
          expect(graetzl_name).to eq(@naschmarkt.name)
        end
      end

      context 'with two results' do
        let(:seestadt) { build(:seestadt) }

        before do
          fill_in :address, with: "#{seestadt.street_name}"
          click_button('Weiter')
        end

        it 'shows options to choose graetzl' do
          expect(page).to have_field('graetzl', type: 'radio', count: 2)
        end

        describe 'when choosen' do

          before do
            input_id = "graetzl_#{@seestadt_aspern.id}"
            choose(input_id)
            click_button('Weiter')
          end

          it 'redirects to new_user_registration' do
            expect(page).to have_text('Willkommen im Seestadt Aspern')
          end          

          it 'injects session values in hidden form' do
            puts seestadt.street_name         
            street_name = find('#user_address_attributes_street_name', visible: false).value
            coords = find('#user_address_attributes_coordinates', visible: false).value
            graetzl_name = find('#user_graetzl_attributes_name', visible: false).value

            expect(street_name).to eq(seestadt.street_name)
            expect(coords).to eq(seestadt.coordinates.as_text)
            expect(graetzl_name).to eq(@seestadt_aspern.name)
          end
        end
      end

      context 'with more results' do
        before do
          fill_in :address, with: 'qwertzuiopü'
          click_button('Weiter')
        end

        it 'shows select to choose graetzl' do
          expect(page).to have_selector('select#graetzl')
        end

        describe 'when choosen' do

          before do
            select(@naschmarkt.short_name, from: 'graetzl')
            click_button('Weiter')
          end

          it 'redirects to new_user_registration' do
            expect(page).to have_text('Willkommen im Naschmarkt')
          end          

          it 'injects graetzl and empty address values in hidden form' do
            street_name = find('#user_address_attributes_street_name', visible: false).value
            coords = find('#user_address_attributes_coordinates', visible: false).value
            graetzl_name = find('#user_graetzl_attributes_name', visible: false).value

            expect(street_name).to eq(nil)
            expect(coords).to eq(nil)
            expect(graetzl_name).to eq(@naschmarkt.name)
          end
        end
      end
    end
  end
end