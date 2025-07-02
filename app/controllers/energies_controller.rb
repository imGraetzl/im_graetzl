class EnergiesController < ApplicationController
  MAX_FEED_SIZE = 1000

  def index
    head :ok and return if browser.bot? && !request.format.js?

    # Meetings: Upcoming, sortiert nach starts_at_date ASC, max 15
    meetings_upcoming = if params[:user_id].present?
      []
    else
      meeting_category = EventCategory.where("title ILIKE :q", q: "%Energieteiler%").last
      Meeting.in(current_region)
        .upcoming
        .include_for_box
        .joins(:event_categories)
        .where(event_categories: {id: meeting_category&.id})
        .order(:starts_at_date)
        .limit(15)
        .to_a
    end

    # Energy Offers & Demands, sortiert nach last_activated_at, gemeinsam
    offers = energy_offers_scope.in(current_region).includes(:user, :energy_categories)
    offers = filter_offers(offers).by_currentness.to_a

    demands = energy_demands_scope.in(current_region).includes(:user, :energy_categories)
    demands = filter_demands(demands).by_currentness.to_a

    offers_and_demands = (offers + demands).sort_by(&:last_activated_at).reverse

    # Gesamtfeed (erst Meetings, dann Offers/Demands), limitieren für Performance
    feed = (meetings_upcoming + offers_and_demands).first(MAX_FEED_SIZE)

    page     = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 15).to_i
    @energies = Kaminari.paginate_array(feed).page(page).per(per_page)
  end

  private

  def energy_offers_scope
    if params[:district_id].present?
      district = District.find(params[:district_id])
      EnergyOffer.joins(:energy_offer_graetzls).where(energy_offer_graetzls: {graetzl_id: district.graetzl_ids}).distinct
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
      user.energy_offers.enabled
    else
      EnergyOffer.all
    end
  end

  def energy_demands_scope
    if params[:district_id].present?
      district = District.find(params[:district_id])
      EnergyDemand.joins(:energy_demand_graetzls).where(energy_demand_graetzls: {graetzl_id: district.graetzl_ids}).distinct
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
      user.energy_demands.enabled
    else
      EnergyDemand.all
    end
  end

  def filter_offers(offers)
    energy_type = params.dig(:filter, :energy_type)
    if energy_type.present? && energy_type != 'offer'
      return EnergyOffer.none
    end

    offers = offers.enabled

    energy_category_ids = params.dig(:filter, :energy_category_ids)&.select(&:present?)
    if energy_category_ids.present?
      offers = offers.joins(:energy_offer_categories).where(energy_offer_categories: {energy_category_id: energy_category_ids}).distinct
    end

    if params[:category_id].present?
      offers = offers.joins(:energy_offer_categories).where(energy_offer_categories: {energy_category_id: params[:category_id]}).distinct
    end

    graetzl_ids = params.dig(:filter, :graetzl_ids)&.select(&:present?)
    if params[:favorites].present? && current_user
      favorite_ids = current_user.followed_graetzl_ids
      offers = offers.joins(:energy_offer_graetzls).where(energy_offer_graetzls: {graetzl_id: favorite_ids}).distinct
    elsif graetzl_ids.present?
      offers = offers.joins(:energy_offer_graetzls).where(energy_offer_graetzls: {graetzl_id: graetzl_ids}).distinct
    end

    offers
  end

  def filter_demands(demands)
    energy_type = params.dig(:filter, :energy_type)
    if energy_type.present? && energy_type != 'demand'
      return EnergyDemand.none
    end

    demands = demands.enabled

    energy_category_ids = params.dig(:filter, :energy_category_ids)&.select(&:present?)
    if energy_category_ids.present?
      demands = demands.joins(:energy_demand_categories).where(energy_demand_categories: {energy_category_id: energy_category_ids}).distinct
    end

    if params[:category_id].present?
      demands = demands.joins(:energy_demand_categories).where(energy_demand_categories: {energy_category_id: params[:category_id]}).distinct
    end

    graetzl_ids = params.dig(:filter, :graetzl_ids)&.select(&:present?)
    if params[:favorites].present? && current_user
      favorite_ids = current_user.followed_graetzl_ids
      demands = demands.joins(:energy_demand_graetzls).where(energy_demand_graetzls: {graetzl_id: favorite_ids}).distinct
    elsif graetzl_ids.present?
      demands = demands.joins(:energy_demand_graetzls).where(energy_demand_graetzls: {graetzl_id: graetzl_ids}).distinct
    end

    demands
  end

  def filter_meetings(meetings)

    energy_type = params.dig(:filter, :energy_type)
    if energy_type.present? && energy_type != 'meeting'
      return Meeting.none
    end

    graetzl_ids = params.dig(:filter, :graetzl_ids)

    if params[:favorites].present? && current_user
      meetings = meetings.where(graetzl_id: current_user.followed_graetzl_ids)
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      meetings = meetings.where(graetzl_id: graetzl_ids)
    end

    meetings
  end

end
