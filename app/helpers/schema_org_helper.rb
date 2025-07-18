module SchemaOrgHelper
  def structured_data_tag(object)
    return unless object

    data =
      case object
      when Meeting
        structured_data_meeting(object)
      when Location
        structured_data_location(object)
      when RoomOffer
        structured_data_room_offer(object)
      when RoomDemand
        structured_data_room_demand(object)
      end

    return unless data

    ordered_data = ActiveSupport::OrderedHash.new
    ordered_data["@context"] = "https://schema.org"
    data.each { |k, v| ordered_data[k] = v }
    content_tag(:script, ordered_data.to_json.html_safe, type: 'application/ld+json')
    
  end

  # //////////////////////////// Create Structured Data for MEETINGS
  def structured_data_meeting(meeting)
    hash = { "@type" => "Event" }
    hash["name"] = meeting.name
    hash["description"] = meeting.description if meeting.description.present?

    if meeting.starts_at_date
      hash["startDate"] = I18n.localize(meeting.starts_at_date, format: '%Y-%m-%d')
      hash["startDate"] += "T#{I18n.localize(meeting.starts_at_time, format: '%H:%M')}+01:00" if meeting.starts_at_time
    end

    if meeting.ends_at_date
      hash["endDate"] = I18n.localize(meeting.ends_at_date, format: '%Y-%m-%d')
      hash["endDate"] += "T#{I18n.localize(meeting.ends_at_time, format: '%H:%M')}+01:00" if meeting.ends_at_time
    elsif meeting.starts_at_date
      hash["endDate"] = I18n.localize(meeting.starts_at_date, format: '%Y-%m-%d')
      hash["endDate"] += "T#{I18n.localize(meeting.ends_at_time, format: '%H:%M')}+01:00" if meeting.ends_at_time
    end

    hash["image"] = meeting.cover_photo_url || asset_url('meta/og_logo.png')
    hash["url"] = graetzl_meeting_url(meeting.graetzl, meeting)
    hash["eventStatus"] = "https://schema.org/EventScheduled"

    if meeting.online_meeting?
      hash["eventAttendanceMode"] = "https://schema.org/OnlineEventAttendanceMode"
      hash["location"] = {
        "@type" => "VirtualLocation",
        "url" => graetzl_meeting_url(meeting.graetzl, meeting)
      }
    else
      hash["eventAttendanceMode"] = "https://schema.org/OfflineEventAttendanceMode"
      location_hash = { "@type" => "Place" }
      if meeting.using_address?
        location_hash["name"] = meeting.address_description if meeting.address_description.present?
        location_hash["address"] = structured_data_address(meeting)
      end
      if meeting.location
        location_hash["name"] = meeting.location.name
        location_hash["image"] = meeting.location.cover_photo_url || asset_url('meta/og_logo.png')
        location_hash["sameAs"] = graetzl_location_url(meeting.location.graetzl, meeting.location)
      end
      hash["location"] = location_hash
    end

    hash["organizer"] = structured_data_person(meeting.user) if meeting.user

    hash
  end

  # //////////////////////////// Create Structured Data for ADDRESS
  def structured_data_address(object)
    hash = { "@type" => "PostalAddress" }
    hash["streetAddress"] = object.address_street if object.address_street.present?
    hash["addressLocality"] = object.address_city if object.address_city.present?
    hash["addressRegion"] = object.address_city if object.address_city.present?
    hash["postalCode"] = object.address_zip if object.address_zip.present?
    hash["addressCountry"] = "AT"
    hash
  end

  # //////////////////////////// Create Structured Data for PERSONS
  def structured_data_person(user)
    hash = { "@type" => "Person" }
    hash["name"] = user.full_name
    hash["image"] = user.avatar_url || asset_url('meta/og_logo.png')
    hash
  end

  # //////////////////////////// Create Structured Data for LOCATIONS
  def structured_data_location(location)
    hash = { "@type" => "LocalBusiness" }
    hash["@id"] = graetzl_location_url(location.graetzl, location)
    hash["url"] = graetzl_location_url(location.graetzl, location)
    hash["name"] = location.name
    hash["slogan"] = location.slogan if location.slogan.present?
    hash["description"] = truncate(location.description.to_s.gsub(/[\r\n]+/, " "), length: 300) if location.description.present?
    hash["email"] = location.email if location.email.present?
    hash["telephone"] = location.phone if location.phone.present?
    hash["address"] = structured_data_address(location) if location.using_address?
    hash["logo"] = location.avatar_url || asset_url('fallbacks/location_avatar.png')
    hash["founder"] = structured_data_person(location.user) if location.user

    images = []
    images << location.cover_photo_url if location.cover_photo_url.present?
    if location.images.respond_to?(:each)
      location.images.each do |img|
        img_url = img.file_url if img.respond_to?(:file_url)
        images << img_url if img_url.present? && !images.include?(img_url)
      end
    end
    images << asset_url('meta/og_logo.png') if images.empty?
    hash["image"] = images.size == 1 ? images.first : images

    if location.address_coordinates.present?
      hash["geo"] = {
        "@type" => "GeoCoordinates",
        "longitude" => location.address_coordinates.x,
        "latitude" => location.address_coordinates.y
      }
    end

    if location.upcoming_meetings.present?
      next_location_event = location.upcoming_meetings.where.not(starts_at_date: nil).sort_by(&:starts_at_date).first
      hash["event"] = structured_data_meeting(next_location_event) unless next_location_event.nil?
    end

    same_as = []
    same_as << location.website_url if location.website_url.present?
    same_as << location.online_shop_url if location.online_shop_url.present?
    hash["sameAs"] = same_as if same_as.any?

    hash
  end

  # //////////////////////////// Create Structured Data for ROOM_OFFERS
  def structured_data_room_offer(room_offer)
    hash = { "@type" => "RentAction" }
    hash["object"] = { "@type" => "Room" }
    hash["object"]["name"] = t("activerecord.attributes.room_offer.offer_types.#{room_offer.offer_type}") + ': ' + room_offer.slogan
    hash["object"]["address"] = structured_data_address(room_offer) if room_offer.using_address?
    hash["image"] = room_offer.cover_photo_url || asset_url('meta/og_logo.png')
    hash["landlord"] = structured_data_person(room_offer.user) if room_offer.user
    hash["landlord"] = structured_data_location(room_offer.location) if room_offer.location
    hash
  end

  # //////////////////////////// Create Structured Data for ROOM_DEMANDS
  def structured_data_room_demand(room_demand)
    hash = { "@type" => "Person" }
    if room_demand.first_name.present? && room_demand.last_name.present?
      hash["name"] = "#{room_demand.first_name} #{room_demand.last_name}"
    end
    hash["image"] = room_demand.avatar_url || asset_url('meta/og_logo.png')
    hash["description"] = room_demand.personal_description if room_demand.personal_description
    hash["seeks"] = t("activerecord.attributes.room_demand.demand_types.#{room_demand.demand_type}") + ': ' + room_demand.slogan
    hash
  end
end
