module SchemaOrg
  module References

    # Collects up to `limit` image URLs (cover + gallery)
    def schema_org_images(object, cover_method: :cover_photo_url, images_method: :images, file_method: :file_url, placeholder: nil, limit: 5)
      images = [object.send(cover_method)].compact

      if object.respond_to?(images_method)
        images += Array(object.send(images_method)).map { |img| img.send(file_method) if img.respond_to?(file_method) }
      end

      images << placeholder if images.compact.blank? && placeholder.present?
      images.compact.uniq.first(limit)
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
      hash["addressRegion"] = object.address_city if object.address_city.present?
      hash["postalCode"] = object.address_zip if object.address_zip.present?
      hash["addressCountry"] = "AT"
      hash
    end

    # Create Structured Data Reference for USERS
    def schema_org_person_reference(user, host: Rails.application.routes.default_url_options[:host])
      hash = { "@type" => "Person" }
      hash["name"] = user.full_name
      hash["image"] = user.avatar_url || asset_url('meta/og_logo.png')
      hash
    end

    # Create Structured Data Reference for MEETINGS
    def schema_org_meeting_reference(meeting, start_date: nil, start_time: nil, end_time: nil, host: Rails.application.routes.default_url_options[:host])
      {
        "@type"     => "Event",
        "url"       => graetzl_meeting_url(meeting.graetzl, meeting, host: host),
        "name"      => meeting.name,
        "startDate" => iso8601_in_vienna(start_date || meeting.starts_at_date, start_time),
        "endDate"   => iso8601_in_vienna(start_date || meeting.starts_at_date, end_time)
      }
    end

    # Create Structured Data Reference for LOCATIONS
    def schema_org_location_reference(location, host: Rails.application.routes.default_url_options[:host])
      hash = { "@type" => "LocalBusiness" }
      hash["@id"]  = graetzl_location_url(location.graetzl, location, host: host)
      hash["url"]  = graetzl_location_url(location.graetzl, location, host: host)
      hash["name"] = location.name
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

  end
end
