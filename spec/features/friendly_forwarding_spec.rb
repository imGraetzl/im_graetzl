require 'rails_helper'

RSpec.feature 'FriendlyForwarding', type: :feature do
  let(:user) { create(:user) }
  let!(:district) { create(:district, zip: '1020') }

  scenario 'user requests resource which requires authentication' do
    visit edit_user_path

    expect(page).to have_selector('div.alert', text: 'Du musst Dich anmelden oder registrieren, bevor Du fortfahren kannst.')

    fill_in :user_login, with: user.username
    fill_in :user_password, with: user.password
    click_button 'Anmelden'

    expect(page).to have_selector('h2', text: 'Zugangsdaten für deinen Account')
  end

  scenario 'user logs in without previously requesting a resource' do
    visit new_user_session_path

    expect(page).to have_selector('h1', text: 'In deinem Grätzl anmelden')

    fill_in :user_login, with: user.username
    fill_in :user_password, with: user.password
    click_button 'Anmelden'

    expect(page).to have_selector('h3', text: "Neues im #{user.graetzl.name} Stream")
  end
end
