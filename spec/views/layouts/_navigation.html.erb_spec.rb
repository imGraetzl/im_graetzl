require 'rails_helper'

RSpec.describe 'layouts/_navigation', type: :view do

  shared_examples :basic_navigation do
    it 'displays link to discover graetzls' do
      expect(rendered).to have_link('Grätzl entdecken', href: districts_path)
    end
  end

  shared_examples :basic_logged_in do
    it 'displays link to create meeting' do
      expect(rendered).to have_link('Treffen anlegen', href: new_graetzl_meeting_path(user.graetzl))
    end

    it 'displays link to home graetzl' do
      expect(rendered).to have_xpath("//a[@href='#{graetzl_path(user.graetzl)}']")
    end

    it 'does not display link to register' do
      expect(rendered).not_to have_link('Kostenlos registrieren', href: user_registration_address_path)
    end

    it 'does not display link to login' do
      expect(rendered).not_to have_link('Anmelden', href: new_user_session_path)
    end

    it 'displays link to logout' do
      expect(rendered).to have_link('Abmelden', href: destroy_user_session_path)
    end
  end

  context 'when logged out' do
    before { render }

    it_behaves_like :basic_navigation

    it 'displays link to root' do
      expect(response).to have_xpath("//a[@href='/']")
    end

    it 'displays link create_meeting to login' do
      expect(rendered).to have_link('Treffen anlegen', href: new_user_session_path)
    end

    it 'displays link to register' do
      expect(rendered).to have_link('Kostenlos registrieren', href: user_registration_address_path)
    end

    it 'displays link to login' do
      expect(rendered).to have_link('Anmelden', href: new_user_session_path)
    end

    it 'displays link to settings' do
      pending('not implemented yet')
      expect(rendered).to have_link('Profileinstellungen')
    end
  end

  context 'when logged in as normal user' do
    let!(:user) { create(:user) }

    before do
      sign_in user
      render
    end

    it_behaves_like :basic_navigation

    it_behaves_like :basic_logged_in

    it 'does not display link to admin pages' do
      expect(rendered).not_to have_link('Admin', href: admin_root_path)
    end
  end

  context 'when logged in as admin user' do
    let!(:user) { create(:user_admin) }

    before do
      sign_in user
      render
    end

    it_behaves_like :basic_navigation

    it_behaves_like :basic_logged_in

    it 'displays link to admin pages' do
      expect(rendered).to have_link('Admin', href: admin_root_path)
    end
  end
end