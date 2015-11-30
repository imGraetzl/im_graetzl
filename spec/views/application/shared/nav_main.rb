RSpec.shared_examples :nav_district do
  it 'displays link to home' do
    expect(rendered).to have_link('Home', href: '/')
  end

  it 'displays link to district overview' do
    expect(rendered).to have_link('Wien Übersicht', href: districts_path)
  end

  it 'displays dropdown to discover district' do
    expect(rendered).to have_selector('span.txt', text: district.name)
  end

  it 'displays link to district_meetings' do
    expect(rendered).to have_link("Treffen & Events im #{district.numeric}. Bezirk", href: district_meetings_path(district))
  end

  it 'displays link to district_locations' do
    expect(rendered).to have_link("Treffpunkte & Anbieter im #{district.numeric}. Bezirk", href: district_locations_path(district))
  end
end

RSpec.shared_examples :nav_graetzl do

  it 'displays link to home' do
    expect(rendered).to have_link('Home', href: '/')
  end

  it 'displays link to district overview' do
    expect(rendered).to have_link('Wien Übersicht', href: districts_path)
  end

  it 'displays dropdown to discover graetzl' do
    expect(rendered).to have_selector('span.txt', text: graetzl.name)
  end

  it 'displays link to graetzl_meetings' do
    expect(rendered).to have_link('Treffen & Events im Grätzl', href: graetzl_meetings_path(graetzl))
  end

  it 'displays link to graetzl_locations' do
    expect(rendered).to have_link('Treffpunkte & Anbieter', href: graetzl_locations_path(graetzl))
  end
end
