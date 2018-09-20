module SchemaOrgHelper

  def structured_data_tag (type, object)
    hash = {:@context => 'http://www.schema.org'}
    final_hash = hash.merge(structured_data_meeting(object)) if type == 'meeting'
    content_tag(:script, final_hash.to_json, {type: 'application/ld+json'}, false) # false is used here to prevent html character escaping
  end

  # Create Structured Data for Locations
  def structured_data_location (location)
    hash = {:@type => 'Place'}
    hash[:name] = location.name
    return hash
  end

  # Create Structured Data for Meetings
  def structured_data_meeting (meeting)
    hash = {:@type => 'Event'}
    hash[:name] = meeting.name
    hash[:description] = meeting.description
    hash[:startDate] = I18n.localize(meeting.starts_at_date, format:'%Y-%m-%d') if meeting.starts_at_date
    hash[:image] = attachment_url(meeting, :cover_photo, host: request.url, fallback: 'meta/og_logo.png')
    hash[:url] = meeting_url(meeting)
    if meeting.location
      hash[:location] = structured_data_location(meeting.location)
    end
    return hash
  end

end
