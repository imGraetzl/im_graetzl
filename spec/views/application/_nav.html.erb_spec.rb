require 'rails_helper'
require 'views/application/shared/nav_personal'
require 'views/application/shared/nav_main'

RSpec.describe 'application/_nav', type: :view do

  context 'when logged out and no district or graetzl' do
    before { render }

    it 'displays link to home' do
      expect(rendered).to have_link('Home', href: '/')
    end

    it 'displays link to district overview' do
      expect(rendered).to have_link('Wien Übersicht', href: districts_path)
    end

    it 'displays dropdown to discover graetzls' do
      expect(rendered).to have_selector('span.txt', text: 'Grätzl entdecken')
    end

    it 'does not displays link to graetzl_meetings' do
      expect(rendered).not_to have_link('Treffen & Events im Grätzl')
    end

    it 'does not link to graetzl_locations' do
      expect(rendered).not_to have_link('Treffpunkte & Anbieter')
    end

    it 'displays link to registration' do
      expect(rendered).to have_link('Kostenlos registrieren', href: new_registration_path)
    end

    it 'displays link to login' do
      expect(rendered).to have_link('Anmelden', href: new_user_session_path)
    end
  end

  context 'when logged out and district' do
    let(:district) { create :district }
    before do
      assign(:district, district)
      render
    end

    it_behaves_like :nav_district

    it 'displays link to registration' do
      expect(rendered).to have_link('Kostenlos registrieren', href: new_registration_path)
    end

    it 'displays link to login' do
      expect(rendered).to have_link('Anmelden', href: new_user_session_path)
    end
  end

  context 'when logged out and graetzl' do
    let(:graetzl) { create :graetzl }
    before do
      assign(:graetzl, graetzl)
      render
    end

    it_behaves_like :nav_graetzl

    it 'displays link to registration' do
      expect(rendered).to have_link('Kostenlos registrieren', href: new_registration_path)
    end

    it 'displays link to login' do
      expect(rendered).to have_link('Anmelden', href: new_user_session_path)
    end
  end

  context 'when logged in and no district or graetzl' do
    let(:graetzl) { create(:graetzl) }
    let(:user) { create(:user, graetzl: graetzl) }
    before do
      sign_in user
      render
    end

    it_behaves_like :nav_graetzl

    it_behaves_like :nav_personal_user
  end

  context 'when logged in and district' do
    let(:user) { create :user }
    let(:district) { create :district }
    before do
      sign_in user
      assign(:district, district)
      render
    end

    it_behaves_like :nav_district

    it_behaves_like :nav_personal_user
  end

  context 'when logged in and graetzl' do
    let(:user) { create :user }
    let(:graetzl) { create :graetzl }
    before do
      sign_in user
      assign(:graetzl, graetzl)
      render
    end

    it_behaves_like :nav_graetzl

    it_behaves_like :nav_personal_user
  end
end
#
#
#
#     before { render }
#
#     include_examples :nav_main_basic
#
#     it 'displays dropdown to discover graetzl' do
#       expect(rendered).to have_selector('span.txt', text: 'Grätzl entdecken')
#     end
#
#     it 'does not displays link to graetzl_meetings' do
#       expect(rendered).not_to have_link('Treffen im Grätzl')
#     end
#
#     it 'displays link to graetzl_locations' do
#       expect(rendered).not_to have_link('Kreative Wirtschaft im Grätzl')
#     end
#
#
#
#
#
#
#   # Shared Examples
#   shared_examples :nav_main_basic do
#     it 'displays link to home' do
#       expect(rendered).to have_link('Home', href: '/')
#     end
#
#     it 'displays link to district overview' do
#       expect(rendered).to have_link('Wien Übersicht', href: districts_path)
#     end
#   end
#
#   shared_examples :nav_main_graetzl do
#
#     it 'displays dropdown to discover current graetzl' do
#       expect(rendered).to have_selector('span.txt', text: current_graetzl.name)
#     end
#
#     it 'does not display dropdown to discover graetzl in general' do
#       expect(rendered).not_to have_selector('span.txt', text: 'Grätzl entdecken')
#     end
#
#     it 'displays link to show current graetz' do
#       expect(rendered).to have_link(current_graetzl.name, href: graetzl_path(current_graetzl))
#     end
#
#     it 'displays link to graetzl_meetings' do
#       expect(rendered).to have_link('Treffen & Events im Grätzl', href: graetzl_meetings_path(current_graetzl))
#     end
#
#     it 'displays link to graetzl_locations' do
#       expect(rendered).to have_link('Treffpunkte & Anbieter', href: graetzl_locations_path(current_graetzl))
#     end
#
#     it 'displays link to zuckerls#index in 1020' do
#       expect(rendered).to have_link("Grätzlzuckerl im #{l(Date.today, format: '%B')}",
#         href: zuckerl_districts_path)
#     end
#
#     # it 'displays link to home graetzl' do
#     #   expect(rendered).to have_xpath("//a[@href='#{graetzl_path(user.graetzl)}']")
#     # end
#   end
#
#
#   # Scenarios
#   let(:graetzl) { create(:graetzl, state: Graetzl.states[:open]) }
#
#   context 'when logged out' do
#     describe 'nav/main' do
#       context 'with graetzl context' do
#         before do
#           assign(:graetzl, graetzl)
#           render
#         end
#
#         include_examples :nav_main_basic
#
#         include_examples :nav_main_graetzl do
#           let(:current_graetzl) { graetzl }
#         end
#       end
#       context 'without graetzl context' do
#         before { render }
#
#         include_examples :nav_main_basic
#
#         it 'displays dropdown to discover graetzl' do
#           expect(rendered).to have_selector('span.txt', text: 'Grätzl entdecken')
#         end
#
#         it 'does not displays link to graetzl_meetings' do
#           expect(rendered).not_to have_link('Treffen im Grätzl')
#         end
#
#         it 'displays link to graetzl_locations' do
#           expect(rendered).not_to have_link('Kreative Wirtschaft im Grätzl')
#         end
#       end
#     end
#     describe 'nav/personal' do
#       before { render }
#
#       it 'displays link to registration' do
#         expect(rendered).to have_link('Kostenlos registrieren', href: new_registration_path)
#       end
#
#       it 'displays link to login' do
#         expect(rendered).to have_link('Anmelden', href: new_user_session_path)
#       end
#     end
#   end
#   context 'when logged in' do
#     let(:user_graetzl) { create(:graetzl, state: Graetzl.states[:open]) }
#     let(:user) { create(:user, graetzl: user_graetzl) }
#     before { sign_in user }
#     describe 'nav/main' do
#       context 'with graetzl context' do
#         before do
#           assign(:graetzl, graetzl)
#           render
#         end
#
#         include_examples :nav_main_basic
#
#         include_examples :nav_main_graetzl do
#           let(:current_graetzl) { graetzl }
#         end
#       end
#       context 'without graetzl context' do
#         before { render }
#
#         include_examples :nav_main_basic
#
#         include_examples :nav_main_graetzl do
#           let(:current_graetzl) { user_graetzl }
#         end
#
#       end
#     end
#     describe 'nav/personal' do
#       before { render }
#
#       it 'displays link to start meeting' do
#         expect(rendered).to have_link('Treffen anlegen', href: new_meeting_path)
#       end
#
#       it 'displays link to profile' do
#         expect(rendered).to have_link('Profil', href: user_path(user))
#       end
#
#       it 'displays link to locations' do
#         expect(rendered).to have_link('Locations', href: locations_user_path)
#       end
#
#       it 'displays link to edit profile' do
#         expect(rendered).to have_link('Einstellungen', href: edit_user_path)
#       end
#
#       it 'displays link to logout' do
#         expect(rendered).to have_link('Abmelden', href: destroy_user_session_path)
#       end
#     end
#   end
# end
