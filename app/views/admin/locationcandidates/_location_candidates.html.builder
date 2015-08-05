context.instance_eval do
  table_for Address.where(addressable_type: 'Meeting').where.not(description: '') do
    column :beschreibung do |address|
      address.description
    end
    column :adresse do |address|
      "#{address.street_name} #{address.street_number}, #{address.zip} #{address.city}"
    end
    column :graetzl do |address|
      address.graetzl.name
    end
    column :kontext do |address|
      address.addressable
    end
    column :erstellt do |address|
      I18n.l address.created_at
    end
    column '' do |address|
      link_to 'Location Erstellen', nil, class: 'btn-light'
    end
  end
end