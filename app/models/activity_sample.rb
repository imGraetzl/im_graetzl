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

  def tool_offers
    if @graetzl
      @graetzl.tool_offers.in(@current_region).enabled.by_currentness.first(2)
    elsif @district
      @district.tool_offers.in(@current_region).enabled.by_currentness.first(2)
    else
      ToolOffer.in(@current_region).enabled.by_currentness.first(2)
    end
  end

  def rooms
    room_call = RoomCall.in(@current_region).open_calls.first
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
    [room_call, room_offer, room_demand].compact.first(2)
  end

  def zuckerls
    if @graetzl
      Zuckerl.for_area(@graetzl).include_for_box.order(Arel.sql("RANDOM()")).first(2)
    elsif @district
      Zuckerl.for_area(@district).include_for_box.order(Arel.sql("RANDOM()")).first(2)
    else
      Zuckerl.live.include_for_box.order(Arel.sql("RANDOM()")).first(2)
    end
  end

end
