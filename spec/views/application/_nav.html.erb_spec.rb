require 'rails_helper'

RSpec.describe 'application/_nav', type: :view do
  # Shared Examples
  shared_examples :nav_main_basic do
    it 'displays link to home' do
      expect(rendered).to have_link('Home', href: '/')
    end

    it 'displays link to district overview' do
      expect(rendered).to have_link('Wien Übersicht', href: districts_path)
    end
  end

  shared_examples :nav_main_graetzl do

    it 'displays dropdown to discover current graetzl' do
      expect(rendered).to have_selector('span.txt', text: current_graetzl.name)
    end

    it 'does not display dropdown to discover graetzl in general' do
      expect(rendered).not_to have_selector('span.txt', text: 'Grätzl entdecken')
    end

    it 'displays link to graetzl_meetings' do
      expect(rendered).to have_link('Treffen im Grätzl', href: graetzl_meetings_path(current_graetzl))
    end

    it 'displays link to graetzl_locations' do
      expect(rendered).to have_link('Kreative Wirtschaft im Grätzl', href: graetzl_locations_path(current_graetzl))
    end

    # it 'displays link to home graetzl' do
    #   expect(rendered).to have_xpath("//a[@href='#{graetzl_path(user.graetzl)}']")
    # end
  end


  # Scenarios
  let(:graetzl) { create(:graetzl) }

  context 'when logged out' do
    describe 'nav/main' do
      context 'with graetzl context' do
        before do
          assign(:graetzl, graetzl)
          render
        end

        include_examples :nav_main_basic

        include_examples :nav_main_graetzl do
          let(:current_graetzl) { graetzl }
        end
      end
      context 'without graetzl context' do
        before { render }

        include_examples :nav_main_basic

        it 'displays dropdown to discover graetzl' do
          expect(rendered).to have_selector('span.txt', text: 'Grätzl entdecken')
        end

        it 'does not displays link to graetzl_meetings' do
          expect(rendered).not_to have_link('Treffen im Grätzl')
        end

        it 'displays link to graetzl_locations' do
          expect(rendered).not_to have_link('Kreative Wirtschaft im Grätzl')
        end
      end
    end
    describe 'nav/personal' do
      before { render }

      it 'displays link to start meeting pointing to login' do
        expect(rendered).to have_link('Treffen anlegen', href: new_user_session_path)
      end

      it 'displays link to login' do
        expect(rendered).to have_link('Anmelden', href: new_user_session_path)
      end
    end
  end
  context 'when logged in' do
    let(:user_graetzl) { create(:graetzl) }
    let(:user) { create(:user, graetzl: user_graetzl) }
    before { sign_in user }
    describe 'nav/main' do
      context 'with graetzl context' do
        before do
          assign(:graetzl, graetzl)
          render
        end

        include_examples :nav_main_basic

        include_examples :nav_main_graetzl do
          let(:current_graetzl) { graetzl }
        end
      end
      context 'without graetzl context' do
        before { render }

        include_examples :nav_main_basic
        
        include_examples :nav_main_graetzl do
          let(:current_graetzl) { user_graetzl }
        end

      end
    end
    describe 'nav/personal' do
      before { render }

      it 'displays link to start meeting' do
        expect(rendered).to have_link('Treffen anlegen', href: new_meeting_path)
      end

      it 'displays link to logout' do
        expect(rendered).to have_link('Abmelden', href: destroy_user_session_path)
      end
    end
  end
end