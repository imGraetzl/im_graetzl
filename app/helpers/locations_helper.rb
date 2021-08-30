module LocationsHelper

  def location_meta(location)
    [location.full_address, location.description].compact.join(" | ").truncate(154)
  end

end
