module SchemaOrgHelper

  def structured_data_tag (object)
    hash = {:@context => 'http://www.schema.org'}
    if object.class.name == 'Meeting'
      final_hash = hash.merge(structured_data_meeting(object))
    elsif object.class.name == 'Location'
      final_hash = hash.merge(structured_data_location(object))
    elsif object.class.name == 'RoomOffer'
      final_hash = hash.merge(structured_data_room_offer(object))
    elsif object.class.name == 'RoomDemand'
      final_hash = hash.merge(structured_data_room_demand(object))
    end
    content_tag(:script, final_hash.to_json, {type: 'application/ld+json'}, false) if final_hash
  end

  # //////////////////////////// Create Structured Data for MEETINGS
  def structured_data_meeting (meeting)

    hash = {:@type => 'Event'}
    hash[:name] = meeting.name
    hash[:description] = meeting.description if meeting.description.present?
    hash[:startDate] = I18n.localize(meeting.starts_at_date, format:'%Y-%m-%d') if meeting.starts_at_date
    hash[:startDate] += "T#{I18n.localize(meeting.starts_at_time, format:'%H:%M')}" if meeting.starts_at_time
    hash[:endDate] = I18n.localize(meeting.starts_at_date, format:'%Y-%m-%d') if meeting.starts_at_date # days is same as startdate
    hash[:endDate] += "T#{I18n.localize(meeting.ends_at_time, format:'%H:%M')}" if meeting.ends_at_time
    hash[:image] = attachment_url(meeting, :cover_photo, host: url_for(:only_path => false, :overwrite_params => nil), fallback: 'meta/og_logo.png')
    hash[:url] = graetzl_meeting_url(meeting.graetzl, meeting)
    hash[:eventStatus] = 'https://schema.org/EventScheduled'

    if meeting.online_meeting?
      hash[:eventAttendanceMode] = 'https://schema.org/OnlineEventAttendanceMode'
      hash[:location] = {:@type => 'VirtualLocation'} # Object for Virtual Event Location
      hash[:location][:url] = graetzl_meeting_url(meeting.graetzl, meeting)
    else
      hash[:eventAttendanceMode] = 'https://schema.org/OfflineEventAttendanceMode'
      hash[:location] = {:@type => 'Place'} # Object for Event Location or Address
      if meeting.display_address # Take Adress from Meeting
        hash[:location][:name] = meeting.display_address.description if meeting.display_address.description
        hash[:location][:address] = structured_data_address(meeting.display_address)
      end
      if meeting.location # If Location exists
        hash[:location][:name] = meeting.location.name
        hash[:location][:image] = attachment_url(meeting.location, :cover_photo, host: url_for(:only_path => false, :overwrite_params => nil), fallback: 'meta/og_logo.png')
        hash[:location][:sameAs] = graetzl_location_url(meeting.location.graetzl, meeting.location)
      end
    end

    if meeting.user # Creator of Meeting
      hash[:organizer] = structured_data_person(meeting.user)
    end

    return hash

  end

  # //////////////////////////// Create Structured Data for ADDRESS
  def structured_data_address (address)
    hash = {:@type => 'PostalAddress'}
    hash[:streetAddress] = address.street if address.street
    hash[:addressLocality] = address.city if address.city
    hash[:addressRegion] = address.city if address.city
    hash[:postalCode] = address.zip if address.zip
    hash[:addressCountry] = 'AT'
    return hash
  end

  # //////////////////////////// Create Structured Data for PERSONS
  def structured_data_person (user)
    hash = {:@type => 'Person'}
    hash[:name] = user.full_name
    hash[:image] = attachment_url(user, :avatar, host: url_for(:only_path => false, :overwrite_params => nil), fallback: 'meta/og_logo.png')
    return hash
  end

  # //////////////////////////// Create Structured Data for LOCATIONS
  def structured_data_location (location)
    hash = {:@type => 'LocalBusiness'}
    hash[:name] = location.name
    hash[:slogan] = location.slogan if location.slogan.present?
    hash[:description] = location.description if location.description.present?
    hash[:url] = graetzl_location_url(location.graetzl, location)
    hash[:logo] = attachment_url(location, :avatar, host: url_for(:only_path => false, :overwrite_params => nil), fallback: 'avatar/location/400x400.png')
    hash[:image] = attachment_url(location, :cover_photo, host: url_for(:only_path => false, :overwrite_params => nil), fallback: 'meta/og_logo.png')
    hash[:email] = location.contact.email if location.contact.email.present?
    hash[:telephone] = location.contact.phone if location.contact.phone.present?
    hash[:address] = structured_data_address(location.address) if location.address
    if location.address.try(:coordinates)
      hash[:geo] = {:@type => 'GeoCoordinates'}
      hash[:geo][:latitude] = location.address.coordinates.y
      hash[:geo][:longitude] = location.address.coordinates.x
    end

    if location.upcoming_meetings.present?
      next_location_event = location.upcoming_meetings.where.not(starts_at_date: nil).sort_by(&:starts_at_date).first
      hash[:event] = structured_data_meeting(next_location_event) unless next_location_event.nil?
    end

    return hash
  end

  # //////////////////////////// Create Structured Data for ROOM_OFFERS
  def structured_data_room_offer (room_offer)
    hash = {:@type => 'RentAction'}
    hash[:object] = {:@type => 'Room'}
    hash[:object][:name] = t("activerecord.attributes.room_offer.offer_types.#{room_offer.offer_type}") + ': ' + room_offer.slogan
    hash[:object][:address] = structured_data_address(room_offer.address) if room_offer.address
    hash[:image] = attachment_url(room_offer, :cover_photo, host: url_for(:only_path => false, :overwrite_params => nil), fallback: 'meta/og_logo.png')
    hash[:landlord] = structured_data_person(room_offer.user) if room_offer.user
    hash[:landlord] = structured_data_location(room_offer.location) if room_offer.location
    return hash
  end

  # //////////////////////////// Create Structured Data for ROOM_DEMANDS
  def structured_data_room_demand (room_demand)
    hash = {:@type => 'Person'}
    hash[:name] = room_demand.first_name + ' ' + room_demand.last_name if room_demand.first_name.present? && room_demand.last_name.present?
    hash[:image] = attachment_url(room_demand, :avatar, host: url_for(:only_path => false, :overwrite_params => nil), fallback: 'meta/og_logo.png')
    hash[:description] = room_demand.personal_description if room_demand.personal_description
    hash[:seeks] = t("activerecord.attributes.room_demand.demand_types.#{room_demand.demand_type}") + ': ' + room_demand.slogan
    return hash
  end

end
