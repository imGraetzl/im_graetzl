module SchemaOrg
  class Meeting < Base

    def initialize(object, host:)
      super
      @meeting = object
    end

    def to_schema
      hash = { "@type" => "Event" }
      hash["@id"] = graetzl_meeting_url(@meeting.graetzl, @meeting, host: @host)
      hash["url"] = graetzl_meeting_url(@meeting.graetzl, @meeting, host: @host)
      hash["eventStatus"] = "https://schema.org/EventScheduled"
      hash["name"] = clean_for_schema(@meeting.name) if @meeting.name.present?
      hash["description"] = clean_for_schema(strip_tags(@meeting.description.bbcode_to_html).truncate(300)) if @meeting.description.present?
      hash["startDate"] = iso8601_in_vienna(@meeting.starts_at_date, @meeting.starts_at_time) if @meeting.starts_at_date
      hash["endDate"] = iso8601_in_vienna(@meeting.ends_at_date.presence || @meeting.starts_at_date, @meeting.ends_at_time) if @meeting.ends_at_date || @meeting.starts_at_date
      hash["image"] = schema_org_images(@meeting, placeholder: asset_url('meta/og_logo.png'), limit: 5)
      hash["location"] = build_event_location(@meeting, host: @host)

      if @meeting.location
        hash["organizer"] = schema_org_location_reference(@meeting.location, host: @host)
      elsif @meeting.user
        hash["organizer"] = schema_org_person_reference(@meeting.user, host: @host)
      end

      if @meeting.event_categories.any?
        titles = @meeting.event_categories.map(&:title).compact.uniq
        hash["keywords"] = titles.compact.join(', ') if titles.any?
      end

      if @meeting.meeting_additional_dates.any?
        hash["subEvent"] = @meeting.meeting_additional_dates
          .order(:starts_at_date, :starts_at_time)
          .limit(5)
          .map do |date_obj|
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
