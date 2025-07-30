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
    hash["@id"] = graetzl_location_url(meeting.graetzl, meeting)
    hash["url"] = graetzl_meeting_url(meeting.graetzl, meeting)
    hash["eventStatus"] = "https://schema.org/EventScheduled"
    hash["name"] = meeting.name
    hash["description"] = strip_tags(meeting.description.bbcode_to_html).truncate(300) if meeting.description.present?
    hash["startDate"] = iso8601_in_vienna(meeting.starts_at_date, meeting.starts_at_time)
    hash["endDate"]   = iso8601_in_vienna(meeting.ends_at_date.presence || meeting.starts_at_date, meeting.ends_at_time)
    hash["image"] = meeting.cover_photo_url || asset_url('meta/og_logo.png')

    if meeting.location
      hash["organizer"] = structured_data_location_reference(meeting.location)
    elsif meeting.user
      hash["organizer"] = structured_data_person_reference(meeting.user)
    end

    if meeting.event_categories.any?
      titles = meeting.event_categories.map(&:title).compact.uniq
      hash["keywords"] = titles.join(', ')
    end

    if meeting.online_meeting?
      hash["eventAttendanceMode"] = "https://schema.org/OnlineEventAttendanceMode"
      location_hash = {
        "@type" => "VirtualLocation",
        "url"   => meeting.online_url.presence || graetzl_meeting_url(meeting.graetzl, meeting)
      }
      location_hash["name"] = meeting.online_description if meeting.online_description.present?
      hash["location"] = location_hash

    else
      hash["eventAttendanceMode"] = "https://schema.org/OfflineEventAttendanceMode"
      location_hash = { "@type" => "Place" }
      location_hash["name"] = meeting.address_description if meeting.address_description.present?
      if meeting.address_street.present? || meeting.address_city.present?
        location_hash["address"] = structured_data_address(meeting)
      end
      if meeting.address_coordinates.present?
        location_hash["geo"] = {
          "@type" => "GeoCoordinates",
          "longitude" => meeting.address_coordinates.x,
          "latitude" => meeting.address_coordinates.y
        }
      end
      hash["location"] = location_hash
    end

    if meeting.meeting_additional_dates.any?
      hash["subEvent"] = meeting.meeting_additional_dates.order(:starts_at_date, :starts_at_time).map do |date_obj|
        structured_data_meeting_reference(
          meeting,
          start_date: date_obj.starts_at_date,
          start_time: date_obj.starts_at_time,
          end_time: date_obj.ends_at_time
        )
      end
    end

    hash
  end


  # //////////////////////////// Create Structured Data for LOCATIONS
  def structured_data_location(location)
    hash = { "@type" => "LocalBusiness" }
    hash["@id"] = graetzl_location_url(location.graetzl, location)
    hash["url"] = graetzl_location_url(location.graetzl, location)
    hash["name"] = location.name
    hash["slogan"] = location.slogan if location.slogan.present?
    hash["description"] = strip_tags(location.description).truncate(300) if location.description.present?
    hash["email"] = location.email if location.email.present?
    hash["telephone"] = location.phone if location.phone.present?
    hash["address"] = structured_data_address(location) if location.using_address?
    hash["logo"] = location.avatar_url || asset_url('fallbacks/location_avatar.png')
    hash["founder"] = structured_data_person_reference(location.user) if location.user

    keywords = []
    keywords << location.location_category.name if location.location_category
    keywords += location.products.pluck(:name) if location.respond_to?(:products)
    hash["keywords"] = keywords.uniq.join(", ") if keywords.any?

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

    if location.upcoming_meetings.any?
      hash["event"] = location.upcoming_meetings
                        .where.not(starts_at_date: nil)
                        .order(:starts_at_date, :starts_at_time)
                        .limit(5)
                        .map { |meeting| structured_data_meeting_reference(meeting) }
    end

    same_as = []
    same_as << location.website_url if location.website_url.present?
    same_as << location.online_shop_url if location.online_shop_url.present?
    hash["sameAs"] = same_as if same_as.any?

    hash
  end


  # //////////////////////////// Create Structured Data for ROOM_OFFERS
  def structured_data_room_offer(room_offer)
    hash = { "@type" => "Offer" }
    hash["@id"] = room_offer_url(room_offer)
    hash["url"] = room_offer_url(room_offer)
    hash["name"] = room_offer.slogan.presence || "Raum zu vermieten"
    hash["description"] = strip_tags(room_offer.room_description.bbcode_to_html).truncate(300) if room_offer.room_description.present?
    hash["availability"] = "https://schema.org/InStock"

    # Bilder sammeln
    images = [room_offer.cover_photo_url]
    if room_offer.images.respond_to?(:each)
      room_offer.images.each { |img| images << img.file_url if img.respond_to?(:file_url) }
    end
    images << asset_url('meta/og_logo.png') if images.compact.blank?
    hash["image"] = images.compact.uniq if images.any?

    # POTENTIAL ACTION (nur bei Online-Buchung)
    if room_offer.rental_enabled?
      hash["potentialAction"] = {
        "@type" => "ReserveAction",
        "target" => "#{room_offer_url(room_offer)}#booking-box"
      }
    end

    # Categories
    if room_offer.room_categories.present?
      hash["category"] = room_offer.room_categories.map(&:name)
    end

    # priceSpecification für verschiedene Raumteilerpakete
    price_specs = []
    if room_offer.room_offer_prices.present?
      room_offer.room_offer_prices.order(:amount).each do |price|
        spec = {
          "@type" => "UnitPriceSpecification",
          "name" => price.name.presence || "Preisangebot"
        }
        if price.amount.present?
          spec["price"] = price.amount.to_s
          spec["priceCurrency"] = "EUR"
        end
        price_specs << spec
      end
    end

    # Onlinebuchung – als weitere priceSpecs für RoomRentals
    if room_offer.rental_enabled? && room_offer.respond_to?(:room_rental_price) && room_offer.room_rental_price
      rental = room_offer.room_rental_price
      if rental.price_per_hour.present?
        price_specs << {
          "@type" => "UnitPriceSpecification",
          "name" => "Stundentarif",
          "price" => rental.price_per_hour.to_s,
          "priceCurrency" => "EUR",
          "unitText" => "HOUR",
          "eligibleQuantity" => { 
            "@type" => "QuantitativeValue", 
            "unitCode" => "HUR", 
            "value" => 1 
          }
        }
      end
      if rental.daily_price.present?
        desc = "Tagestarif (8 Stunden)"
        desc += ", #{rental.eight_hour_discount}% Rabatt" if rental.eight_hour_discount.present? && rental.eight_hour_discount.to_i > 0
        
        price_specs << {
          "@type" => "UnitPriceSpecification",
          "name" => desc,
          "price" => rental.daily_price.to_s,
          "priceCurrency" => "EUR",
          "unitText" => "DAY",
          "eligibleQuantity" => { 
            "@type" => "QuantitativeValue", 
            "unitCode" => "DAY", 
            "value" => 1 
          }
        }
      end
    end
    price_specs.sort_by! { |spec| spec["price"].to_f } if price_specs.any?
    hash["priceSpecification"] = price_specs if price_specs.any?

    # Das Raum-Objekt (itemOffered)
    room = { "@type" => "LocalBusiness" }
    room["name"] = room_offer.slogan.presence || "Raum zu vermieten"
    room["description"] = strip_tags(room_offer.room_description.bbcode_to_html).truncate(200) if room_offer.room_description.present?
    room["image"] = images.compact.uniq if images.any?
    room["address"] = structured_data_address(room_offer)
    # Fläche zur Miete (additionalProperty, im Raumobjekt)
    if room_offer.rented_area.present?
      room["additionalProperty"] ||= []
      room["additionalProperty"] << {
        "@type" => "PropertyValue",
        "name" => "Fläche zur Miete",
        "value" => room_offer.rented_area,
        "unitCode" => "MTK"
      }
    end
    # Ausstattung (amenityFeature, im Raumobjekt)
    if room_offer.keyword_list.present?
      room["amenityFeature"] = room_offer.keyword_list.map do |keyword|
        { "@type" => "LocationFeatureSpecification", "name" => keyword }
      end
    end
    # openingHours aus RoomOfferAvailability generieren
    if room_offer.room_offer_availability.present?
      availability = room_offer.room_offer_availability
      opening_hours = []
      
      # Wochentage mapping (day_0 = Sonntag, day_1 = Montag, etc.)
      days_mapping = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
      
      (0..6).each do |day_index|
        from_hour = availability.send("day_#{day_index}_from")
        to_hour = availability.send("day_#{day_index}_to")
        
        if from_hour.present? && to_hour.present?
          # Stunden zu HH:MM Format konvertieren
          from_time = sprintf("%02d:00", from_hour)
          to_time = sprintf("%02d:00", to_hour)
          
          day_code = days_mapping[day_index]
          opening_hours << "#{day_code} #{from_time}-#{to_time}"
        end
      end
      room["openingHours"] = opening_hours if opening_hours.any?
    end
    hash["itemOffered"] = room

    # Vermieter*in/Kontakt
    hash["seller"] =
      if room_offer.location.present?
        structured_data_location_reference(room_offer.location)
      elsif room_offer.user.present?
        structured_data_person_reference(room_offer.user)
      end

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

  
  # //////////////////////////// HELPERS ////////////////////////////

  # //////////////////////////// Create Structured Data Reference for ADDRESS
  def structured_data_address(object)
    hash = { "@type" => "PostalAddress" }
    hash["streetAddress"] = object.address_street if object.address_street.present?
    hash["addressLocality"] = object.address_city if object.address_city.present?
    hash["addressRegion"] = object.address_city if object.address_city.present?
    hash["postalCode"] = object.address_zip if object.address_zip.present?
    hash["addressCountry"] = "AT"
    hash
  end

  # //////////////////////////// Create Structured Data Reference for USERS
  def structured_data_person_reference(user)
    hash = { "@type" => "Person" }
    hash["name"] = user.full_name
    hash["image"] = user.avatar_url || asset_url('meta/og_logo.png')
    hash
  end

  # //////////////////////////// Create Structured Data Reference for MEETINGS
  def structured_data_meeting_reference(meeting, start_date: nil, start_time: nil, end_time: nil)
    {
      "@type"     => "Event",
      "url"       => graetzl_meeting_url(meeting.graetzl, meeting),
      "name"      => meeting.name,
      "startDate" => iso8601_in_vienna(start_date || meeting.starts_at_date, start_time),
      "endDate"   => iso8601_in_vienna(start_date || meeting.starts_at_date, end_time)
    }
  end

  # //////////////////////////// Create Structured Data Reference for LOCATIONS
  def structured_data_location_reference(location)
    hash = { "@type" => "LocalBusiness" }
    hash["@id"]  = graetzl_location_url(location.graetzl, location)
    hash["url"]  = graetzl_location_url(location.graetzl, location)
    hash["name"] = location.name
    hash["image"] = location.cover_photo_url || asset_url('meta/og_logo.png')
    hash
  end

  # //////////////////////////// Date / Time Helper for ISO8601 in Vienna Timezone
  def iso8601_in_vienna(date, time = nil)
    return nil unless date

    if time
      dt = Time.zone.local(date.year, date.month, date.day, time.hour, time.min)
      dt.in_time_zone('Vienna').iso8601
    else
      date.strftime('%Y-%m-%d')
    end
  end

end
