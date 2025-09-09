class ActivitySample
  DEFAULT_EXPIRES = 10.minutes

  def initialize(graetzl: nil, district: nil, current_region: nil)
    @graetzl = graetzl
    @district = district
    @current_region = current_region
  end

  def meetings
    scope = if @graetzl
      if @current_region.use_districts?
        @graetzl.district.meetings
      else
        Meeting
      end
    elsif @district
      @district.meetings
    else
      Meeting
    end

    cached(:meetings) { load_for(:meetings, scope.in(@current_region).include_for_box.by_currentness) }
  end

  def groups
    scope = if @graetzl
      @graetzl.groups
    elsif @district
      @district.groups
    else
      Group
    end

    cached(:groups) { load_for(:groups, scope.in(@current_region).featured.include_for_box) }
  end

  def locations
    scope = if @graetzl
      @graetzl.locations
    elsif @district
      @district.locations
    else
      Location
    end

    cached(:locations) do
      load_for(:locations, scope.in(@current_region).approved.include_for_box.by_currentness).tap do |locations|
        @actual_newest_post_map ||= locations.index_with(&:actual_newest_post)
      end
    end
  end

  def crowd_campaigns
    cached(:crowd_campaigns, expires_in: 15.minutes) do
      funding = CrowdCampaign.in(@current_region).region.funding
        .or(CrowdCampaign.platform.funding)
        .by_currentness.limit(2).to_a

      if funding.size >= 2
        funding
      else
        completed = CrowdCampaign.in(@current_region).region.completed.successful.enabled
          .or(CrowdCampaign.platform.completed.successful.enabled)
          .by_currentness.limit(2 - funding.size).to_a
        (funding + completed).uniq.first(2)
      end
    end
  end

  def coop_demands
    scope = if @graetzl
      @graetzl.coop_demands
    elsif @district
      @district.coop_demands
    else
      CoopDemand
    end

    cached(:coop_demands) { load_for(:coop_demands, scope.in(@current_region).enabled.include_for_box.by_currentness) }
  end

  def rooms
    cached(:rooms) do
      offers = if @graetzl
        @graetzl.room_offers.in(@current_region).enabled.include_for_box.by_currentness.limit(2).to_a
      elsif @district
        @district.room_offers.in(@current_region).enabled.include_for_box.by_currentness.limit(2).to_a
      else
        RoomOffer.in(@current_region).enabled.include_for_box.by_currentness.limit(2).to_a
      end

      demands = if @graetzl
        @graetzl.room_demands.in(@current_region).enabled.include_for_box.by_currentness.limit(2).to_a
      elsif @district
        @district.room_demands.in(@current_region).enabled.include_for_box.by_currentness.limit(2).to_a
      else
        RoomDemand.in(@current_region).enabled.include_for_box.by_currentness.limit(2).to_a
      end

      (offers.first(1) + demands.first(1)).tap do |result|
        rest = (offers + demands) - result
        result.concat(rest.first(2 - result.size)) if result.size < 2
      end
    end
  end

  def energies
    cached(:energies) do
      offer = if @graetzl
        @graetzl.energy_offers.in(@current_region).enabled.by_currentness.first
      elsif @district
        @district.energy_offers.in(@current_region).enabled.by_currentness.first
      else
        EnergyOffer.in(@current_region).enabled.by_currentness.first
      end

      demand = if @graetzl
        @graetzl.energy_demands.in(@current_region).enabled.by_currentness.first
      elsif @district
        @district.energy_demands.in(@current_region).enabled.by_currentness.first
      else
        EnergyDemand.in(@current_region).enabled.by_currentness.first
      end

      [offer, demand].compact.first(2)
    end
  end

  def polls
    scope = if @graetzl
      @graetzl.polls
    elsif @district
      @district.polls
    else
      Poll
    end

    cached(:polls) { load_for(:polls, scope.in(@current_region).enabled.by_currentness) }
  end

  def zuckerls
    cached(:zuckerls) do
      if @graetzl
        Zuckerl.in(@current_region).live.in_area(@graetzl.id).include_for_box.random(2).to_a
      elsif @district
        Zuckerl.in(@current_region).live.in_area(@district.graetzl_ids).include_for_box.random(2).to_a
      else
        Zuckerl.in(@current_region).live.include_for_box.random(2).to_a
      end
    end
  end

  private

  def load_for(name, scope)
    instance_variable_get("@#{name}") || instance_variable_set("@#{name}", scope.limit(2).to_a)
  end

  def cached(name, expires_in: DEFAULT_EXPIRES)
    key = ["activity_sample", name, cache_scope_key]
    Rails.cache.fetch(key, expires_in: expires_in) { yield }
  end

  def cache_scope_key
    [@graetzl&.id, @district&.id, @current_region&.id]
  end
end
