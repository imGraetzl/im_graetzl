module LocationsHelper

  def location_meta(location)
    [location.full_address, location.description].compact.join(" | ").truncate(154)
  end

  def address_short(location)
    if location.region.use_districts?
      "#{location.address_zip}, #{location.address_street}"
    else
      "#{location.address_street}, #{location.address_city}"
    end
  end

  def actual_newest_post_for(location)
    return @actual_newest_post_map[location.id] if defined?(@actual_newest_post_map)
    location.actual_newest_post
  end

  def actual_newest_menu_for(location)
    # Nur wenn Map vorhanden
    if defined?(@actual_newest_post_map)
      newest = @actual_newest_post_map[location.id]
      return newest if newest.is_a?(LocationMenu)
    end

    # Fallback wenn keine Map vorhanden
    location.location_menus.select { |m| m.menu_to > Date.yesterday }.max_by(&:created_at)
  end

end
