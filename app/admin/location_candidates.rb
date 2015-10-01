ActiveAdmin.register_page 'location_candidates' do
  #menu parent: 'Locations', label: 'Kandidaten'
  menu false

  content title: 'Location Kandidaten' do
    panel 'Location Kandidaten Adressen' do
      render 'admin/locations/candidates_table', compact: false
    end
  end
end