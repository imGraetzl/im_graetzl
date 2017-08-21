class MeetingsSerializer

  def initialize(meetings)
    @meetings = meetings
  end

  def as_json(options = {})
    @meetings.map do |meeting|
      meeting.slice(
        :id,
        :name,
        :description,
        :created_at,
        :starts_at_date,
        :starts_at_time,
        :ends_at_date,
        :ends_at_time,
      ).merge(
        url: Rails.application.routes.url_helpers.meeting_url(meeting),
        cover_photo_url: meeting.cover_photo.try(:url),
        graetzl: meeting.graetzl.name,
        location: location_fields(meeting.location),
        address: address_fields(meeting.address)
      )
    end
  end

  def location_fields(location)
    location.slice(:id, :name).merge(
      url: Rails.application.routes.url_helpers.location_url(location),
    ) if location
  end

  def address_fields(address)
    address.slice(:street_name, :street_number, :zip, :city)
  end
end
