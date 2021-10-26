json.rooms do
  json.array!(@results.select{|r| r.is_a?(RoomOffer) || r.is_a?(RoomDemand)}) do |room|
    json.type room.class.name
    json.name room.slogan
    if room.is_a?(RoomOffer)
      json.url room_offer_path(room)
      json.icon room.cover_photo_url(:thumb)
    elsif room.is_a?(RoomDemand)
      json.url room_demand_path(room)
      json.icon room.avatar_url(:thumb)
    end
  end
end

json.tools do
  json.array!(@results.select{|r| r.is_a?(ToolOffer) || r.is_a?(ToolDemand)}) do |tool|
    json.type tool.class.name
    if tool.is_a?(ToolOffer)
      json.name tool.title
      json.url tool_offer_path(tool)
      json.icon tool.cover_photo_url(:thumb)
    elsif tool.is_a?(ToolDemand)
      json.name tool.slogan
      json.url tool_demand_path(tool)
      json.icon tool.user.avatar_url(:thumb)
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
    json.icon meeting.cover_photo_url(:thumb)
  end
end

json.locations do
  json.array!(@results.select{|r| r.is_a?(Location)}) do |location|
    json.type location.class.name
    json.name location.name
    json.url graetzl_location_path(location.graetzl, location)
    json.icon location.avatar_url(:thumb)
  end
end

json.coop_demands do
  json.array!(@results.select{|r| r.is_a?(CoopDemand)}) do |coop_demand|
    json.type coop_demand.class.name
    json.name coop_demand.slogan
    json.url coop_demand_path(coop_demand)
    json.icon coop_demand.avatar_url(:thumb)
  end
end

json.groups do
  json.array!(@results.select{|r| r.is_a?(Group)}) do |group|
    json.type group.class.name
    json.name group.title
    json.url group_path(group)
    json.icon group.cover_photo_url(:thumb)
  end
end
