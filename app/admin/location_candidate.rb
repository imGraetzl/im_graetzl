ActiveAdmin.register_page 'LocationCandidates' do
  menu parent: 'Locations', label: 'Kandidaten'

  content do
    panel 'Location Kandidaten Adressen' do
      #render 'location_candidates', context: self
      table_for Address.where(addressable_type: 'Meeting').where.not(description: '').order(created_at: :desc) do
        column :beschreibung do |address|
          address.description
        end
        column :adresse do |address|
          "#{address.street_name} #{address.street_number}, #{address.zip} #{address.city}"
        end
        column :graetzl do |address|
          link_to address.graetzl.name, admin_graetzl_path(address.graetzl)
        end
        column :kontext do |address|
          link_to "Treffen: '#{address.addressable.name}'", '#'
        end
        column :erstellt do |address|
          I18n.l address.created_at
        end
        column '' do |address|
          link_to 'Location Erstellen', nil, class: 'btn-light'
        end
      end
    end
  end
end