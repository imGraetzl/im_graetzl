json.rooms do
  json.array!(@results.select{|r| r.is_a?(RoomOffer) || r.is_a?(RoomDemand)}) do |room|
    json.count @results.find{|r| r[:rooms_count]} [:rooms_count]
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
    json.count @results.find{|r| r[:tools_count]} [:tools_count]
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
    json.count @results.find{|r| r[:meetings_count]} [:meetings_count]
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
    json.count @results.find{|r| r[:locations_count]} [:locations_count]
    json.type location.class.name
    json.name location.name
    json.url graetzl_location_path(location.graetzl, location)
    json.icon location.avatar_url(:thumb)
  end
end

json.coop_demands do
  json.array!(@results.select{|r| r.is_a?(CoopDemand)}) do |coop_demand|
    json.count @results.find{|r| r[:coop_demands_count]} [:coop_demands_count]
    json.type coop_demand.class.name
    json.name coop_demand.slogan
    json.url coop_demand_path(coop_demand)
    json.icon coop_demand.avatar_url(:thumb)
  end
end

json.crowd_campaigns do
  json.array!(@results.select{|r| r.is_a?(CrowdCampaign)}) do |crowd_campaign|
    json.count @results.find{|r| r[:crowd_campaigns_count]} [:crowd_campaigns_count]
    json.type crowd_campaign.class.name
    json.name crowd_campaign.title
    json.url crowd_campaign_path(crowd_campaign)
    json.icon crowd_campaign.cover_photo_url(:thumb)
  end
end

json.polls do
  json.array!(@results.select{|r| r.is_a?(Poll)}) do |poll|
    json.count @results.find{|r| r[:polls_count]} [:polls_count]
    json.type poll.class.name
    json.name poll.title
    json.url poll_path(poll)
    json.icon poll.cover_photo_url(:thumb)
  end
end

json.groups do
  json.array!(@results.select{|r| r.is_a?(Group)}) do |group|
    json.count @results.find{|r| r[:groups_count]} [:groups_count]
    json.type group.class.name
    json.name group.title
    json.url group_path(group)
    json.icon group.cover_photo_url(:thumb)
  end
end

json.energies do
  json.array!(@results.select{|r| r.is_a?(EnergyOffer) || r.is_a?(EnergyDemand)}) do |energy|
    json.count @results.find{|r| r[:energies_count]} [:energies_count]
    json.type energy.class.name
    json.name energy.title
    if energy.is_a?(EnergyOffer)
      json.url energy_offer_path(energy)
      json.icon energy.cover_photo_url(:thumb)
    elsif energy.is_a?(EnergyDemand)
      json.url energy_demand_path(energy)
      json.icon energy.avatar_url(:thumb)
    end
  end
end