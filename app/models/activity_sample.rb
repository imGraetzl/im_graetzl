class ActivitySample

  def initialize(graetzl: nil, district: nil)
    @graetzl = graetzl
    @district = district
  end

  def meetings
    if @graetzl
      @graetzl.meetings.include_for_box.by_currentness.first(2)
    elsif @district
      @district.meetings.include_for_box.by_currentness.first(2)
    else
      Meeting.include_for_box.by_currentness.first(2)
    end
  end

  def locations
    if @graetzl
      @graetzl.locations.approved.include_for_box.order("last_activity_at DESC").first(2)
    elsif @district
      @district.locations.approved.include_for_box.order("last_activity_at DESC").first(2)
    else
      Location.approved.include_for_box.order("last_activity_at DESC").first(2)
    end
  end

  def rooms
    if @graetzl
      room_offers = @graetzl.room_offers.by_currentness.first(2)
      room_demands = @graetzl.room_demands.by_currentness.first(2)
    elsif @district
      room_offers = @district.room_offers.by_currentness.first(2)
      room_demands = @district.room_demands.by_currentness.first(2)
    else
      room_offers = RoomOffer.by_currentness.first(2)
      room_demands = RoomDemand.by_currentness.first(2)
    end
    @rooms = (room_offers + room_demands).sort_by(&:created_at).reverse.first(2)
  end

  def zuckerls
    if @graetzl
      @graetzl.zuckerls.include_for_box.order("RANDOM()").first(2)
    elsif @district
      @district.zuckerls.include_for_box.order("RANDOM()").first(2)
    else
      Zuckerl.live.include_for_box.order("RANDOM()").first(2)
    end
  end

  def posts
    if @graetzl
      @graetzl.posts.where(type: "UserPost").order(created_at: :desc).first(2)
    end
  end

end
