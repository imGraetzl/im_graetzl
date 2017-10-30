class RoomsController < ApplicationController

  def index
    @room_offers = room_offers_scope.includes(:user, :graetzl)
    @room_offers = @room_offers.page(params[:page]).per(15)

    @room_demands = room_demands_scope.includes(:user)
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
end
