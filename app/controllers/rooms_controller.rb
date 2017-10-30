class RoomsController < ApplicationController

  def index
    @room_offers = room_offers_scope.includes(:user, :graetzl)
    @room_offers = filter_offers(@room_offers)
    @room_offers = @room_offers.page(params[:page]).per(15)

    @room_demands = room_demands_scope.includes(:user)
    @room_demands = filter_demands(@room_demands)
    @room_demands = @room_demands.page(params[:page]).per(15)
  end

  private

  def room_offers_scope
    if params[:graetzl_id]
      graetzl = Graetzl.find(params[:graetzl_id])
      graetzl.room_offers
    else
      RoomOffer.all
    end
  end

  def room_demands_scope
    if params[:graetzl_id]
      graetzl = Graetzl.find(params[:graetzl_id])
      graetzl.room_demands
    else
      RoomDemand.all
    end
  end

  def filter_offers(offers)
    if filter_params[:room_type].present?
      action_type, offer_type = filter_params[:room_type].split("-")
      if action_type == 'demand'
        return RoomOffer.none
      elsif offer_type.present?
        offers = offers.where(offer_type: offer_type)
      end
    end

    if filter_params[:room_category_ids].any?(&:present?)
      offers = offers.joins(:room_categories).where(room_categories: {id: filter_params[:room_category_ids]})
    end

    offers
  end

  def filter_demands(demands)
    if filter_params[:room_type].present?
      action_type, demands_type = filter_params[:room_type].split("-")
      if action_type == 'offer'
        return RoomDemand.none
      elsif demands_type.present?
        demands = demands.where(offer_type: demands_type)
      end
    end

    if filter_params[:room_category_ids].any?(&:present?)
      demands = demands.joins(:room_categories).where(room_categories: {id: filter_params[:room_category_ids]})
    end

    demands
  end


  def filter_params
    params.require(:room_filter)
  end

end
