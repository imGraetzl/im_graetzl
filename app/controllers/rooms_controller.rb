class RoomsController < ApplicationController

  def index
    head :ok and return if browser.bot? && !request.format.js?

    room_offers = room_offers_scope.in(current_region).includes(:user)
    room_offers = filter_offers(room_offers)
    room_offers = room_offers.by_currentness.page(params[:page]).per(params[:per_page] || 15)
    room_offers = room_offers.where.not(id: params[:exclude_room_offer].to_i) if params[:exclude_room_offer]

    room_demands = room_demands_scope.in(current_region).includes(:user, :room_categories)
    room_demands = filter_demands(room_demands)
    room_demands = room_demands.by_currentness.page(params[:page]).per(params[:per_page] || 15)

    @rooms = []
    @rooms += (room_offers + room_demands).sort_by(&:last_activated_at).reverse
    @next_page = room_offers.next_page.present? || room_demands.next_page.present?
  end

  private

  def room_offers_scope
    if params[:district_id].present?
      RoomOffer.where(district_id: params[:district_id])
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
      user.room_offers.enabled
    else
      RoomOffer.all
    end
  end

  def room_demands_scope
    if params[:district_id].present?
      district = District.find(params[:district_id])
      RoomDemand.joins(:room_demand_graetzls).where(room_demand_graetzls: {graetzl_id: district.graetzl_ids}).distinct
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
      user.room_demands.enabled
    else
      RoomDemand.all
    end
  end

  def filter_offers(offers)
    room_type = params.dig(:filter, :room_type)
    if room_type.present?
      if room_type == 'with_group'
        offers = offers.where(id: Group.distinct.pluck(:room_offer_id).compact)
      elsif room_type != 'offer'
        return RoomOffer.none
      end
    end

    if params.dig(:filter, :show_occupied).present?
      offers = offers.where(status: [:enabled, :occupied])
    else
      offers = offers.enabled
    end

    room_category_ids = params.dig(:filter, :room_category_ids)&.select(&:present?)
    if room_category_ids.present?
      offers = offers.joins(:room_offer_categories).where(room_offer_categories: {room_category_id: room_category_ids}).distinct
    end

    if params[:special_category_id].present? && params[:special_category_id] == 'kurzzeitmiete'
      offers = offers.rentable
    end

    if params[:category_id].present?
      offers = offers.joins(:room_offer_categories).where(room_offer_categories: {room_category_id: params[:category_id]}).distinct
    end

    graetzl_ids = params.dig(:filter, :graetzl_ids)
    if params[:favorites].present? && current_user
      offers = offers.where(graetzl_id: current_user.followed_graetzl_ids)
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      offers = offers.where(graetzl_id: graetzl_ids)
    end

    offers
  end

  def filter_demands(demands)
    room_type = params.dig(:filter, :room_type)
    if room_type.present? && room_type != 'demand'
      return RoomDemand.none
    end

    if params[:special_category_id].present? && params[:special_category_id] == 'kurzzeitmiete'
      return RoomDemand.none
    end

    demands = demands.enabled

    room_category_ids = params.dig(:filter, :room_category_ids)&.select(&:present?)
    if room_category_ids.present?
      demands = demands.joins(:room_demand_categories).where(room_demand_categories: {room_category_id: room_category_ids}).distinct
    end

    if params[:category_id].present?
      demands = demands.joins(:room_demand_categories).where(room_demand_categories: {room_category_id: params[:category_id]}).distinct
    end

    graetzl_ids = params.dig(:filter, :graetzl_ids)&.select(&:present?)
    if params[:favorites].present? && current_user
      favorite_ids = current_user.followed_graetzl_ids
      demands = demands.joins(:room_demand_graetzls).where(room_demand_graetzls: {graetzl_id: favorite_ids}).distinct
    elsif graetzl_ids.present?
      demands = demands.joins(:room_demand_graetzls).where(room_demand_graetzls: {graetzl_id: graetzl_ids}).distinct
    end

    demands
  end

end
