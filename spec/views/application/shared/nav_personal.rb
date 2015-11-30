RSpec.shared_examples :nav_personal_user do

  it 'displays link to start meeting' do
    expect(rendered).to have_link('Treffen anlegen', href: new_meeting_path)
  end

  it 'displays link to profile' do
    expect(rendered).to have_link('Profil', href: user_path(user))
  end

  it 'displays link to locations' do
    expect(rendered).to have_link('Locations', href: locations_user_path)
  end

  it 'does not display link to admin' do
    expect(rendered).not_to have_link('Admin')
  end

  it 'displays link to edit profile' do
    expect(rendered).to have_link('Einstellungen', href: edit_user_path)
  end

  it 'displays link to logout' do
    expect(rendered).to have_link('Abmelden', href: destroy_user_session_path)
  end
end
