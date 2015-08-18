require 'rails_helper'

RSpec.describe 'meetings/show', type: :view do

  shared_examples :basic_header do
    before { render }

    it 'displays name' do
      expect(rendered).to have_selector('h1', meeting.name)
    end

    it 'displays link to @graezl' do
      expect(rendered).to have_link(graetzl.name)
    end

    describe 'date' do
      context 'when not set' do
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

      context 'when set' do
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

  shared_examples :basic_address do
    context 'when not set' do
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

    context 'with description' do
      before do
        meeting.address = Address.new
        meeting.address.description = 'blabla'
        render
      end

      it 'displays description' do
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

  describe 'render' do
    let(:graetzl) { create(:graetzl) }
    let(:meeting) { create(:meeting, graetzl: graetzl) }
    before do
      assign(:graetzl, graetzl)
      assign(:meeting, meeting)
      assign(:comments, [])
    end

    context 'when logged in' do
      let(:user) { create(:user) }
      before { sign_in user }

      it_behaves_like :basic_header
      it_behaves_like :basic_address

      context 'when not going' do
        it 'displays button to attend' do
          render
          expect(rendered).to have_button('Am Treffen teilnehmen')
        end
      end

      context 'when going' do
        let!(:going_to) { create(:going_to, user: user, meeting: meeting) }
        it 'displays button to no longer attend' do
          render
          expect(rendered).to have_button('Nicht mehr teilnehmen')
        end
      end

      context 'when initiator' do
        let!(:going_to) { create(:going_to, user: user, meeting: meeting, role: GoingTo.roles[:initiator]) }
        it 'displays button to edit' do
          render
          expect(rendered).to have_button('Treffen bearbeiten')
        end
      end
    end

    context 'when location set' do
      let!(:location) { create(:location_managed) }
      before do
        meeting.location = location
        meeting.address.description = location.name
        assign(:meeting, meeting)
        render
      end

      it 'displays link to location' do
        expect(rendered).to have_link(location.name)
      end
    end
  end

  describe 'render location meeting' do

  end
end