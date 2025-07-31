module SchemaOrg
  module References

    # Collects up to `limit` image URLs (cover + gallery)
    def schema_org_images(object, cover_method: :cover_photo_url, images_method: :images, file_method: :file_url, placeholder: nil, limit: 5)
      images = []
      cover = object.send(cover_method) if object.respond_to?(cover_method)
      images << cover if cover.present?

      if object.respond_to?(images_method)
        gallery_images = Array(object.send(images_method)).flatten
        gallery_images.each do |img|
          next if img.blank?
          url = img.respond_to?(file_method) ? img.send(file_method) : img.to_s
          images << url if url.present?
        end
      end

      images << placeholder if images.compact.blank? && placeholder.present?
      images.flatten.compact.map(&:to_s).uniq.first(limit)
    end

    # Create Structured Data Reference for GEO-COORDINATES
    def schema_org_geo(object)
      hash = { "@type" => "GeoCoordinates" }
      hash["longitude"] = object.address_coordinates.x if object.address_coordinates.present?
      hash["latitude"] = object.address_coordinates.y if object.address_coordinates.present?
      hash
    end

    # Create Structured Data Reference for ADDRESS
    def schema_org_address(object)
      hash = { "@type" => "PostalAddress" }
      hash["streetAddress"] = object.address_street if object.address_street.present?
      hash["addressLocality"] = object.address_city if object.address_city.present?
      
      # region.name als Fallback
      if object.address_city.present?
        hash["addressRegion"] = object.address_city
      elsif object.respond_to?(:region) && object.region&.name.present?
        hash["addressRegion"] = object.region.name
      end

      hash["postalCode"] = object.address_zip if object.address_zip.present?
      hash["addressCountry"] = "AT"
      hash
    end

    # Create Structured Data Reference for USERS
    def schema_org_person_reference(user, host:)
      hash = { "@type" => "Person" }
      hash["name"] = user.full_name
      hash["image"] = user.avatar_url || asset_url('meta/og_logo.png')
      hash
    end

    # Create Structured Data Reference for MEETINGS
    def schema_org_meeting_reference(meeting, start_date: nil, start_time: nil, end_time: nil, host:)
      {
        "@type"       => "Event",
        "url"         => graetzl_meeting_url(meeting.graetzl, meeting, host: host),
        "eventStatus" => "https://schema.org/EventScheduled",
        "name"        => clean_for_schema(meeting.name),
        "description" => clean_for_schema(strip_tags(meeting.description.bbcode_to_html).truncate(150)),
        "organizer"   => meeting.location.present? ? schema_org_location_reference(meeting.location, host: host) : schema_org_person_reference(meeting.user, host: host),
        "image"       => schema_org_images(meeting, placeholder: asset_url('meta/og_logo.png'), limit: 1),
        "location"    => build_event_location(meeting, host: host),
        "startDate"   => iso8601_in_vienna(start_date || meeting.starts_at_date, start_time),
        "endDate"     => iso8601_in_vienna(start_date || meeting.starts_at_date, end_time)
      }
    end

    # Create Structured Data for Meeting Event Location
    def build_event_location(meeting, host:)
      if meeting.online_meeting?
        {
          "@type" => "VirtualLocation",
          "url"   => meeting.online_url.presence || graetzl_meeting_url(meeting.graetzl, meeting, host: host),
          "name"  => meeting.online_description.presence
        }.compact
      else
        location_hash = { "@type" => "Place" }
        location_hash["name"] = meeting.address_description if meeting.address_description.present?
        location_hash["address"] = schema_org_address(meeting)
        location_hash["geo"] = schema_org_geo(meeting) if meeting.address_coordinates.present?
        location_hash.compact
      end
    end

    # Create Structured Data Reference for LOCATIONS
    def schema_org_location_reference(location, host:)
      hash = { "@type" => "LocalBusiness" }
      hash["@id"]  = graetzl_location_url(location.graetzl, location, host: host)
      hash["url"]  = graetzl_location_url(location.graetzl, location, host: host)
      hash["name"] = clean_for_schema(location.name)
      hash["image"] = location.cover_photo_url || asset_url('meta/og_logo.png')
      hash
    end

    # Date / Time Helper for ISO8601 in Vienna Timezone
    def iso8601_in_vienna(date, time = nil)
      return nil unless date

      if time
        dt = Time.zone.local(date.year, date.month, date.day, time.hour, time.min)
        dt.in_time_zone('Vienna').iso8601
      else
        date.strftime('%Y-%m-%d')
      end
    end

    # Entfernt Emojis und spezielle Unicode-Symbole
    def clean_for_schema(text)
      emoji_regex = /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]/
      text.to_s.gsub(emoji_regex, '').squish
    end

  end
end
