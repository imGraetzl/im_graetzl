json.rooms do
  json.array!(@results.select{|r| r.is_a?(RoomOffer) || r.is_a?(RoomDemand)}) do |room|
    json.type room.class.name
    json.name room.slogan
    if room.is_a?(RoomOffer)
      json.url room_offer_path(room)
      json.icon attachment_url(room, :cover_photo, :fill, 100, 100, fallback: 'avatar/room_offer/40x40.png')
    elsif room.is_a?(RoomDemand)
      json.url room_demand_path(room)
      json.icon attachment_url(room, :avatar, :fill, 100, 100, fallback: 'avatar/room_demand/40x40.png')
    end
  end
end

json.meetings do
  json.array!(@results.select{|r| r.is_a?(Meeting)}) do |meeting|
    json.type meeting.class.name
    json.name meeting.name
    json.day meeting.starts_at_date.day
    json.month I18n.localize(meeting.starts_at_date, format:'%b')
    json.past_flag meeting_past_flag(meeting)
    json.url graetzl_meeting_path(meeting.graetzl, meeting)
    json.icon attachment_url(meeting, :cover_photo, :fill, 100, 100, fallback: 'avatar/user/40x40.png')
  end
end

json.locations do
  json.array!(@results.select{|r| r.is_a?(Location)}) do |location|
    json.type location.class.name
    json.name location.name
    json.url graetzl_location_path(location.graetzl, location)
    json.icon attachment_url(location, :avatar, :fill, 100, 100, fallback: 'avatar/location/40x40.png')
  end
end

json.tool_offers do
  json.array!(@results.select{|r| r.is_a?(ToolOffer)}) do |tool_offer|
    json.type tool_offer.class.name
    json.name tool_offer.title
    json.url tool_offer_path(tool_offer)
    json.icon attachment_url(tool_offer, :cover_photo, :fill, 100, 100, fallback: 'avatar/tool_offer/40x40.png')
  end
end

json.groups do
  json.array!(@results.select{|r| r.is_a?(Group)}) do |group|
    json.type group.class.name
    json.name group.title
    json.url group_path(group)
    json.icon attachment_url(group, :cover_photo, :fill, 100, 100, fallback: 'avatar/user/40x40.png')
  end
end
