module LocationsHelper

  def edit_status(location)
    if location.new_record?
      'Anlegen'
    else
      if location.users.include?(current_user)
        'Aktualisieren'
      else
        'Übernehmen'
      end
    end   
  end

  def link_to_add_address_fields(name, f)
    new_address = f.object.build_address
    fields = render('address_fields', f: f)
    link_to(name, '#', class: 'add_address_fields btn-secondary',
            data: { fields: fields.gsub('\n','') })
  end
end
