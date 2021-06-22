json.rooms do
  json.array!(@results.select{|r| r.is_a?(RoomOffer) || r.is_a?(RoomDemand)}) do |room|
    json.type room.class.name
    json.name room.slogan
    if room.is_a?(RoomOffer)
      json.url room_offer_path(room)
      json.icon cover_url(room, :thumb)
    elsif room.is_a?(RoomDemand)
      json.url room_demand_path(room)
      json.icon avatar_url(room, :thumb)
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
    json.icon cover_url(meeting, :thumb)
  end
end

json.locations do
  json.array!(@results.select{|r| r.is_a?(Location)}) do |location|
    json.type location.class.name
    json.name location.name
    json.url graetzl_location_path(location.graetzl, location)
    json.icon avatar_url(location, :thumb)
  end
end

json.tool_offers do
  json.array!(@results.select{|r| r.is_a?(ToolOffer)}) do |tool_offer|
    json.type tool_offer.class.name
    json.name tool_offer.title
    json.url tool_offer_path(tool_offer)
    json.icon cover_url(tool_offer, :thumb)
  end
end

json.groups do
  json.array!(@results.select{|r| r.is_a?(Group)}) do |group|
    json.type group.class.name
    json.name group.title
    json.url group_path(group)
    json.icon cover_url(group, :thumb)
  end
end
