class SearchService

  def initialize(query, options = {})
    @query = query.to_s.strip
    @options = options
  end

  def sample
    return [] if @query.length < 3

    search_rooms.first(2) +
    search_meetings.first(2) +
    search_locations.first(2) +
    search_tools.first(2) +
    search_groups.first(2)
  end

  def search
    return [] if @query.length < 3

    results = []
    results += search_rooms if @options[:type].blank? || @options[:type] == 'rooms'
    results += search_meetings if @options[:type].blank? || @options[:type] == 'meetings'
    results += search_locations if @options[:type].blank? || @options[:type] == 'locations'
    results += search_tools if @options[:type].blank? || @options[:type] == 'tool_offers'
    results += search_groups if @options[:type].blank? || @options[:type] == 'groups'

    Kaminari.paginate_array(results).page(@options[:page]).per(@options[:per_page] || 15)
  end

  private

  def like_query
    "%#{@query}%"
  end

  def search_rooms
    room_offers = RoomOffer.enabled.where("slogan ILIKE :q", q: like_query)
    room_demands = RoomDemand.enabled.where("slogan ILIKE :q", q: like_query)
    (room_offers + room_demands).sort_by(&:last_activated_at).reverse
  end

  def search_meetings
    Meeting.where("name ILIKE :q", q: like_query).order('starts_at_date DESC')
  end

  def search_locations
    Location.approved.where("name ILIKE :q", q: like_query).order('created_at DESC')
  end

  def search_tools
    ToolOffer.enabled.where("title ILIKE :q", q: like_query).order('created_at DESC')
  end

  def search_groups
    Group.non_hidden.where("title ILIKE :q", q: like_query).order('created_at DESC')
  end

end