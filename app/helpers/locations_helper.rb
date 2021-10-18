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

end
