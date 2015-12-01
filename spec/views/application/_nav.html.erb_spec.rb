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
