class SearchService

  def initialize(region, query, options = {})
    @region = region
    @query = query.to_s.strip
    @options = options
  end

  def sample
    return [] if @query.length < 3

    search_rooms.first(2) +
    search_meetings.first(2) +
    search_locations.first(2) +
    search_tools.first(2) +
    search_coop_demands.first(2) +
    search_groups.first(2)
  end

  def user
    return [] if @query.length < 3

    search_users.first(10)
  end

  def search
    return [] if @query.length < 3

    results = []
    results += search_meetings if @options[:type].blank? || @options[:type] == 'meetings'
    results += search_groups if @options[:type].blank? || @options[:type] == 'groups'
    results += search_locations if @options[:type].blank? || @options[:type] == 'locations'
    results += search_rooms if @options[:type].blank? || @options[:type] == 'rooms'
    results += search_tools if @options[:type].blank? || @options[:type] == 'tools'
    results += search_coop_demands if @options[:type].blank? || @options[:type] == 'coop_demands'

    Kaminari.paginate_array(results).page(@options[:page]).per(@options[:per_page] || 15)
  end

  private

  def like_query
    "%#{@query.gsub(/\s/, "%")}%"
  end

  def search_rooms
    room_offers = RoomOffer.in(@region).enabled.joins(:room_categories).where("slogan ILIKE :q OR room_categories.name ILIKE :q", q: like_query).distinct
    room_demands = RoomDemand.in(@region).enabled.where("slogan ILIKE :q", q: like_query)
    (room_offers + room_demands).sort_by(&:last_activated_at).reverse
  end

  def search_meetings
    Meeting.in(@region).upcoming.where("name ILIKE :q", q: like_query).order('starts_at_date DESC')
  end

  def search_locations
    Location.in(@region).approved.where("name ILIKE :q", q: like_query).order('created_at DESC')
  end

  def search_tools
    tool_offers = ToolOffer.in(@region).enabled.where("title ILIKE :q", q: like_query).order('created_at DESC')
    tool_demands = ToolDemand.in(@region).enabled.where("slogan ILIKE :q", q: like_query)
    (tool_offers + tool_demands).sort_by(&:created_at).reverse
  end

  def search_coop_demands
    CoopDemand.in(@region).enabled.where("slogan ILIKE :q", q: like_query).order('created_at DESC')
  end

  def search_groups
    Group.in(@region).non_hidden.where("title ILIKE :q", q: like_query).order('created_at DESC')
  end

  def search_users
    User.where("username ILIKE :q OR first_name ILIKE :q OR last_name ILIKE :q", q: like_query).order('created_at DESC').distinct
  end

end
