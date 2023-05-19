class MeetingsSerializer

  def initialize(meetings, request)
    @meetings = meetings
    @request = request
  end

  def as_json(*)
    @meetings.map do |meeting|
      meeting.slice(
        :id,
        :name,
        :description,
        :created_at,
        :updated_at,
        :starts_at_date,
        :starts_at_time,
        :ends_at_date,
        :ends_at_time,
      ).merge(
        url: site_url(:graetzl_meeting_url, meeting.graetzl, meeting),
        cover_photo_url: meeting.cover_photo_url,
        graetzl: meeting.graetzl.name,
        graetzl_url: site_url(:graetzl_url, meeting.graetzl),
        location: location_fields(meeting.location),
        user: user_fields(meeting.user),
        address: address_fields(meeting)
      )
    end
  end

  def user_fields(user)
    user.slice(:id, :username).merge(
      avatar_url: user.avatar_url,
      url: site_url(:user_url, user),
    ) if user
  end

  def location_fields(location)
    location.slice(:id, :name).merge(
      avatar_url: location.avatar_url,
      url: site_url(:graetzl_location_url, location.graetzl, location),
    ) if location
  end

  def address_fields(meeting)
    return if !meeting.using_address?
    {
      address_description: meeting.address_description,
      street_name: meeting.address_street,
      zip: meeting.address_zip,
      city: meeting.address_city,
      coordinates: coordinates_fields(meeting.address_coordinates)
    }
  end

  def coordinates_fields(coordinates)
    {lat: coordinates.y, long: coordinates.x} if coordinates
  end

  def site_url(helper_name, *args)
    Rails.application.routes.url_helpers.public_send(helper_name, *args,
      protocol: @request.protocol, host: @request.host, port: @request.port )
  end
end
