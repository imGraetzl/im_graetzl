class RoomsController < ApplicationController

  def index
    @graetzl = Graetzl.find(params[:graetzl_id])
    @map_data = MapData.call graetzl: @graetzl
    @rooms = collect_room_offers + collect_room_demands
  end

  private

  def collect_room_offers
    room_offers = @graetzl.room_offers
    room_offers.where!(offer_type: params[:room_offer_type]) if params[:room_offer_type].present?
    room_offers.page(params[:page]).per(15)
  end

  def collect_room_demands
    room_demands = @graetzl.room_demands
    room_demands.page(params[:page]).per(15)
  end
end
