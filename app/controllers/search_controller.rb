class SearchController < ApplicationController
  before_action :authenticate_user!
  before_action :force_json, only: [:autocomplete]

  def autocomplete

    return if params[:q].empty? || params[:q].length < 3

    search_phrase = "%#{params[:q]}%"
    room_offers = RoomOffer.enabled.where("slogan ILIKE :q", q: search_phrase).last(2)
    room_demands = RoomDemand.enabled.where("slogan ILIKE :q", q: search_phrase).last(2)
    @rooms = (room_offers + room_demands).sort_by(&:last_activated_at).reverse.last(2)
    @meetings = Meeting.where("name ILIKE :q", q: search_phrase).order('starts_at_date ASC').last(2)
    @locations = Location.approved.where("name ILIKE :q", q: search_phrase).last(2)
    @tool_offers = ToolOffer.enabled.where("title ILIKE :q", q: search_phrase).last(2)
    @groups = Group.where("title ILIKE :q", q: search_phrase).last(2)
  end

  def index

  end

  def results
    head :ok and return if browser.bot? && !request.format.js?

    search_type = params.dig(:filter, :search_type)
    search_phrase = "%#{params[:q]}%"
    @results = []

    if !params[:q].empty? && params[:q].length >= 3

      if search_type == 'rooms'

          room_offers = RoomOffer.enabled.where("slogan ILIKE :q", q: search_phrase)
          room_demands = RoomDemand.enabled.where("slogan ILIKE :q", q: search_phrase)
          @results += (room_offers + room_demands).sort_by(&:last_activated_at).reverse

      elsif search_type == 'meetings'

          @results += Meeting.where("name ILIKE :q", q: search_phrase).order('starts_at_date DESC')

      elsif search_type == 'locations'

          @results += Location.approved.where("name ILIKE :q", q: search_phrase)

      elsif search_type == 'tool_offers'

          @results += ToolOffer.enabled.where("title ILIKE :q", q: search_phrase)

      elsif search_type == 'groups'

          @results += Group.where("title ILIKE :q", q: search_phrase)

      else

          room_offers = RoomOffer.where("slogan ILIKE :q", q: search_phrase)
          room_demands = RoomDemand.where("slogan ILIKE :q", q: search_phrase)
          @results += (room_offers + room_demands).sort_by(&:last_activated_at).reverse
          @results += Location.where("name ILIKE :q", q: search_phrase)
          @results += ToolOffer.where("title ILIKE :q", q: search_phrase)
          @results += Group.where("title ILIKE :q", q: search_phrase)
          @results += Meeting.where("name ILIKE :q", q: search_phrase).order('starts_at_date DESC')

      end
    end

    @results = Kaminari.paginate_array(@results).page(params[:page]).per(params[:per_page] || 15)

  end

  private

  def force_json
    request.format = :json
  end

end
