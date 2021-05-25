module LocationsHelper

  def long_address(location)
    location.address&.street ? "#{location.address&.street}, #{location.address&.zip} #{location.address&.city}" : nil
  end

  def location_meta(location)
    [long_address(location), location.description].compact.join(" | ").truncate(154)
  end

end
