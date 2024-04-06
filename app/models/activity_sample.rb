class ActivitySample

  def initialize(graetzl: nil, district: nil, current_region: nil)
    @graetzl = graetzl
    @district = district
    @current_region = current_region
  end

  def meetings
    if @graetzl
      @graetzl.meetings.in(@current_region).visible_to_all.include_for_box.by_currentness.first(2)
    elsif @district
      @district.meetings.in(@current_region).visible_to_all.include_for_box.by_currentness.first(2)
    else
      Meeting.in(@current_region).visible_to_all.include_for_box.by_currentness.first(2)
    end
  end

  def groups
    if @graetzl
      @graetzl.groups.in(@current_region).featured.include_for_box.first(2)
    elsif @district
      @district.groups.in(@current_region).featured.include_for_box.first(2)
    else
      Group.in(@current_region).featured.include_for_box.first(2)
    end
  end

  def locations
    if @graetzl
      @graetzl.locations.in(@current_region).approved.include_for_box.order("last_activity_at DESC").first(2)
    elsif @district
      @district.locations.in(@current_region).approved.include_for_box.order("last_activity_at DESC").first(2)
    else
      Location.in(@current_region).approved.include_for_box.order("last_activity_at DESC").first(2)
    end
  end
  def crowd_campaigns
    funding_campaigns = CrowdCampaign.in(@current_region).region.funding.or(CrowdCampaign.platform.funding).sample(2)
    public_campaigns = CrowdCampaign.in(@current_region).region.completed.successful.enabled.or(CrowdCampaign.platform.completed.successful.enabled).sample(2)
    campaigns = funding_campaigns + public_campaigns
    campaigns.compact.first(2)
  end

  def coop_demands
    if @graetzl
      @graetzl.coop_demands.in(@current_region).enabled.by_currentness.first(2)
    elsif @district
      @district.coop_demands.in(@current_region).enabled.by_currentness.first(2)
    else
      CoopDemand.in(@current_region).enabled.by_currentness.first(2)
    end
  end

  def rooms
    if @graetzl
      room_offer = @graetzl.room_offers.in(@current_region).enabled.by_currentness.first
      room_demand = @graetzl.room_demands.in(@current_region).enabled.by_currentness.first
    elsif @district
      room_offer = @district.room_offers.in(@current_region).enabled.by_currentness.first
      room_demand = @district.room_demands.in(@current_region).enabled.by_currentness.first
    else
      room_offer = RoomOffer.in(@current_region).enabled.by_currentness.first
      room_demand = RoomDemand.in(@current_region).enabled.by_currentness.first
    end
    [room_offer, room_demand].compact.first(2)
  end

  def energies
    if @graetzl
      energy_offer = @graetzl.energy_offers.in(@current_region).enabled.by_currentness.first
      energy_demand = @graetzl.energy_demands.in(@current_region).enabled.by_currentness.first
    elsif @district
      energy_offer = @district.energy_offers.in(@current_region).enabled.by_currentness.first
      energy_demand = @district.energy_demands.in(@current_region).enabled.by_currentness.first
    else
      energy_offer = EnergyOffer.in(@current_region).enabled.by_currentness.first
      energy_demand = EnergyDemand.in(@current_region).enabled.by_currentness.first
    end
    [energy_offer, energy_demand].compact.first(2)
  end

  def tools
    if @graetzl
      @graetzl.tool_offers.in(@current_region).enabled.by_currentness.first(2)
    elsif @district
      @district.tool_offers.in(@current_region).enabled.by_currentness.first(2)
    else
      ToolOffer.in(@current_region).enabled.by_currentness.first(2)
    end
  end

  def polls
    if @graetzl
      @graetzl.polls.in(@current_region).enabled.by_currentness.first(2)
    elsif @district
      @district.polls.in(@current_region).enabled.by_currentness.first(2)
    else
      Poll.in(@current_region).enabled.by_currentness.first(2)
    end
  end

  def zuckerls
    if @graetzl
      Zuckerl.in(@current_region).live.in_area(@graetzl.id).include_for_box.random(2)
    elsif @district
      Zuckerl.in(@current_region).live.in_area(@district.graetzl_ids).include_for_box.random(2)
    else
      Zuckerl.in(@current_region).live.include_for_box.random(2)
    end
  end

end
