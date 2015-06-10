module MeetingsHelper

  def address_value(address)
    if address.street_name.blank?
      nil
    else
      "#{address.street_name} #{address.street_number}"
    end
  end

  def localize_time(time, format)
    if time
      I18n.localize(time, format: format)
    else
      '???'
    end
  end

  def map_link(coordinates)
    "http://www.openstreetmap.org/?mlat=#{coordinates.y}&mlon=#{coordinates.x}&zoom=18"
  end

  def address_description(address)
    if address.description.present?
      content_tag(:strong, address.description) + tag(:br)
    elsif address.coordinates.blank?
      content_tag(:strong, 'Ort steht noch nicht fest...')
    end
  end

  def address_for_teaser(address)
    if address.description.present?
      address.description
    elsif address.street_name
     "#{address.street_name} #{address.street_number}"
    end    
  end
end
