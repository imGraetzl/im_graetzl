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
end
