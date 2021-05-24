module LocationsHelper

  def location_meta(location)
    [location.address&.street, location.description].compact.join(" | ").truncate(154)
  end

end
