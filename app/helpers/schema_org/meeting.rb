module SchemaOrg
  class Meeting < Base

    def initialize(object, host:)
      super
      @meeting = object
    end

    def to_schema
      hash = { "@type" => "Event" }
      hash["@id"] = graetzl_location_url(@meeting.graetzl, @meeting, host: @host)
      hash["url"] = graetzl_meeting_url(@meeting.graetzl, @meeting, host: @host)
      hash["eventStatus"] = "https://schema.org/EventScheduled"
      hash["name"] = @meeting.name if @meeting.name.present?
      hash["description"] = strip_tags(@meeting.description.bbcode_to_html).truncate(300) if @meeting.description.present?
      hash["startDate"] = iso8601_in_vienna(@meeting.starts_at_date, @meeting.starts_at_time) if @meeting.starts_at_date
      hash["endDate"] = iso8601_in_vienna(@meeting.ends_at_date.presence || @meeting.starts_at_date, @meeting.ends_at_time) if @meeting.ends_at_date || @meeting.starts_at_date
      hash["image"] = @meeting.cover_photo_url.presence || asset_url('meta/og_logo.png')

      if @meeting.location
        hash["organizer"] = schema_org_location_reference(@meeting.location, host: @host)
      elsif @meeting.user
        hash["organizer"] = schema_org_person_reference(@meeting.user, host: @host)
      end

      if @meeting.event_categories.any?
        titles = @meeting.event_categories.map(&:title).compact.uniq
        hash["keywords"] = titles.compact.join(', ') if titles.any?
      end

      if @meeting.online_meeting?
        hash["eventAttendanceMode"] = "https://schema.org/OnlineEventAttendanceMode"
        location_hash = {
          "@type" => "VirtualLocation",
          "url"   => @meeting.online_url.presence || graetzl_meeting_url(@meeting.graetzl, @meeting, host: @host)
        }
        location_hash["name"] = @meeting.online_description if @meeting.online_description.present?
        hash["location"] = location_hash
      else
        hash["eventAttendanceMode"] = "https://schema.org/OfflineEventAttendanceMode"
        location_hash = { "@type" => "Place" }
        location_hash["name"] = @meeting.address_description if @meeting.address_description.present?
        if @meeting.address_street.present? || @meeting.address_city.present?
          location_hash["address"] = schema_org_address(@meeting)
        end
        if @meeting.address_coordinates.present?
          location_hash["geo"] = {
            "@type" => "GeoCoordinates",
            "longitude" => @meeting.address_coordinates.x,
            "latitude" => @meeting.address_coordinates.y
          }
        end
        hash["location"] = location_hash
      end

      if @meeting.meeting_additional_dates.any?
        hash["subEvent"] = @meeting.meeting_additional_dates.order(:starts_at_date, :starts_at_time).map do |date_obj|
          schema_org_meeting_reference(
            @meeting,
            start_date: date_obj.starts_at_date,
            start_time: date_obj.starts_at_time,
            end_time: date_obj.ends_at_time,
            host: @host
          )
        end
      end

      hash.compact
    end
  end
end
