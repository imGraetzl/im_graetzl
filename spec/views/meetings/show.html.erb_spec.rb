require 'rails_helper'

RSpec.describe 'meetings/show', type: :view do
  let(:user) { create(:user) }
  let(:graetzl) { create(:graetzl) }
  let(:meeting) { create(:meeting, graetzl: graetzl) }

  shared_examples :title do
    it 'displays meeting name in title' do
      render template: 'meetings/show', layout: 'layouts/application'
      expect(rendered).to have_title("#{meeting.name} | imGrätzl")
    end
  end

  shared_examples :display_basic_info do
    describe 'header section' do
      describe 'basics' do
        before { render }

        it 'displays name' do
          expect(rendered).to have_selector('h1', meeting.name)
        end

        it 'displays link to @graezl' do
          expect(rendered).to have_link(graetzl.name)
        end
      end

      describe 'date' do
        context 'when date not set' do
          before { render }

          it 'displays day not set note' do
            expect(rendered).to have_content('Tag steht noch nicht fest...')
          end

          it 'displays time not set notes' do
            expect(rendered).to have_content('Beginn: ???')
            expect(rendered).to have_content('Ende: ???')
          end

          it 'displays calendar icon' do
            expect(rendered).to have_selector('svg.icon-calendar-2')
          end
        end

        context 'when date set' do
          before do
            meeting.starts_at_date = 'Thu, 23 Jul 2015'
            meeting.starts_at_time = '15:00'
            meeting.ends_at_time = '16:00'
            render
          end
          
          it 'displays full date' do
            expect(rendered).to have_content('Donnerstag, 23. Juli 2015')
          end

          it 'displays times' do
            expect(rendered).to have_content('Beginn: 15:00')
            expect(rendered).to have_content('Ende: 16:00')
          end

          it 'displays calendar icon' do
            expect(rendered).to have_selector('svg.icon-calendar-2')
          end
        end
      end

      describe 'address' do
        context 'when address not set' do
          before do
            meeting.address = Address.new
            render
          end
          
          it 'displays placeholder' do
            expect(rendered).to have_content('Ort steht noch nicht fest...')
          end

          it 'displays map icon' do
            expect(rendered).to have_selector('svg.icon-map-location')
          end
        end

        context 'with address description' do
          before do
            meeting.address = Address.new
            meeting.address.description = 'blabla'
            render
          end

          it 'displays address description' do
            expect(rendered).to have_selector('strong', 'blabla')
          end

          it 'does not displays map link' do
            expect(rendered).not_to have_selector('a', text: 'Karte')
          end
        end

        context 'with address values' do
          let(:new_address) { create(:address) }
          before do
            meeting.address = new_address
            render
          end

          it 'displays address values' do
            expect(rendered).to have_content(new_address.street_name)
            expect(rendered).to have_content(new_address.street_number)
            expect(rendered).to have_content(new_address.zip)
          end

          it 'does not display placeholder' do
            expect(rendered).not_to have_content('Ort steht noch nicht fest...')
          end

          it 'displays map link' do
            expect(rendered).to have_selector('a', text: 'Karte')
          end
        end

        context 'with address values and description' do
          let(:new_address) { create(:address, description: 'blabla') }
          before do
            meeting.address = new_address
            render
          end
          
          it 'displays address description' do
            expect(rendered).to have_content(new_address.description)
          end
          
          it 'displays address values' do
            expect(rendered).to have_content(new_address.street_name)
            expect(rendered).to have_content(new_address.street_number)
            expect(rendered).to have_content(new_address.zip)
          end

          it 'displays map link' do
            expect(rendered).to have_selector('a', text: 'Karte')
          end
        end
      end

      describe 'initiator' do
        context 'when initiator' do
          let!(:initiator) { create(:user) }

          before do
            create(:going_to, meeting: meeting, user: initiator, role: GoingTo.roles[:initiator])
            render
          end

          it 'displays initor name' do
            expect(rendered).to have_content("Erstellt von #{initiator.username}")
          end
        end

        context 'when no initiator' do
          before { render }

          it 'does not display any initiator info' do
            expect(rendered).not_to have_content('Erstellt von')
          end
        end
      end
    end
  end

  context 'when logged in' do
    before do
      assign(:graetzl, graetzl)
      assign(:meeting, meeting)
      assign(:comments, meeting.comments)
      sign_in user
    end
    it_behaves_like :title
    it_behaves_like :display_basic_info
  end

  context 'when logged out' do
    before do
      assign(:graetzl, graetzl)
      assign(:meeting, meeting)
      assign(:comments, meeting.comments)
    end
    it_behaves_like :title
    it_behaves_like :display_basic_info
  end
end