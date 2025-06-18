class SearchService

  def initialize(region, query, options = {})
    @region = region
    @query = query.to_s.strip
    @options = options
  end

  def sample
    return [] if @query.length < 3

    search_crowd_campaigns.first(2) +
    search_rooms.first(2) +
    search_meetings.first(2) +
    search_locations.first(2) +
    search_coop_demands.first(2) +
    search_groups.first(2) +
    search_polls.first(2) +
    search_energies.first(2) +
    [:rooms_count => search_rooms.length] +
    [:meetings_count => search_meetings.length] +
    [:locations_count => search_locations.length] +
    [:coop_demands_count => search_coop_demands.length] +
    [:crowd_campaigns_count => search_crowd_campaigns.length] +
    [:groups_count => search_groups.length] + 
    [:polls_count => search_polls.length] +
    [:energies_count => search_energies.length]
  end

  def user
    return [] if @query.length < 3

    search_users.first(10)
  end

  def search
    if @query.length < 3
      return Kaminari.paginate_array([]).page(@options[:page] || 1).per(@options[:per_page] || 15)
    end

    results = []
    results += search_meetings if @options[:type].blank? || @options[:type] == 'meetings'
    results += search_crowd_campaigns if @options[:type].blank? || @options[:type] == 'crowd_campaigns'
    results += search_groups if @options[:type].blank? || @options[:type] == 'groups'
    results += search_locations if @options[:type].blank? || @options[:type] == 'locations'
    results += search_rooms if @options[:type].blank? || @options[:type] == 'rooms'
    results += search_polls if @options[:type].blank? || @options[:type] == 'polls'
    results += search_energies if @options[:type].blank? || @options[:type] == 'energies'
    results += search_coop_demands if @options[:type].blank? || @options[:type] == 'coop_demands'

    Kaminari.paginate_array(results).page(@options[:page] || 1).per(@options[:per_page] || 15)
  end

  private

  def like_query
    "%#{@query.gsub(/\s/, "%")}%"
  end

  def exact_query
    @query.strip
  end

  def search_rooms
    room_offer_title_matches = RoomOffer.in(@region).enabled.joins(:room_categories).where("slogan ILIKE :q OR room_categories.name ILIKE :q", q: like_query).distinct
    room_offer_tag_matches = RoomOffer.in(@region).enabled.tagged_with(exact_query, any: true)
    room_offers = RoomOffer.where(id: room_offer_title_matches.pluck(:id) + room_offer_tag_matches.pluck(:id))

    room_demand_title_matches = RoomDemand.in(@region).enabled.where("slogan ILIKE :q", q: like_query)
    room_demand_tag_matches = RoomDemand.in(@region).enabled.tagged_with(exact_query, any: true)
    room_demands = RoomDemand.where(id: room_demand_title_matches.pluck(:id) + room_demand_tag_matches.pluck(:id))

    (room_offers + room_demands).sort_by(&:last_activated_at).reverse
  end

  def search_meetings
    Meeting.in(@region).upcoming.left_outer_joins(:location).where("meetings.name ILIKE :q OR locations.name ILIKE :q", q: like_query).order('starts_at_date DESC')
  end

  def search_crowd_campaigns
    CrowdCampaign.in(@region).scope_public.where("title ILIKE :q OR slogan ILIKE :q", q: like_query).order('created_at DESC')
  end

  def search_locations
    title_matches = Location.in(@region).approved.where("name ILIKE :q OR slogan ILIKE :q", q: like_query)
    tag_matches = Location.in(@region).approved.tagged_with(exact_query, any: true)
    Location.where(id: title_matches.pluck(:id) + tag_matches.pluck(:id)).sort_by(&:last_activity_at).reverse
  end

  def search_polls
    Poll.in(@region).enabled.where("title ILIKE :q OR description ILIKE :q", q: like_query).order('created_at DESC')
  end

  def search_energies
    energy_offers = EnergyOffer.in(@region).enabled.where("title ILIKE :q", q: like_query)
    energy_demands = EnergyDemand.in(@region).enabled.where("title ILIKE :q", q: like_query)
    (energy_offers + energy_demands).sort_by(&:last_activated_at).reverse
  end

  def search_coop_demands
    CoopDemand.in(@region).enabled.where("slogan ILIKE :q", q: like_query).order('created_at DESC')
  end

  def search_groups
    Group.in(@region).non_hidden.where("title ILIKE :q", q: like_query).order('created_at DESC')
  end

  def search_users
    User.in(@region).registered.where("username ILIKE :q OR first_name ILIKE :q OR last_name ILIKE :q", q: like_query).order('created_at DESC').distinct
  end

end
