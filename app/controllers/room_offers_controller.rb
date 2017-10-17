class RoomOffersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @room_offers = RoomOffer.all.page(params[:page]).per(15)
  end

  def show
    @room_offer = RoomOffer.find(params[:id])
  end

  def new
    @room_offer = RoomOffer.new
  end

  def edit
    @room_offer = RoomOffer.find(params[:id])
  end

  def create
    @room_offer = RoomOffer.new(room_offer_params)

    if @room_offer.save
      redirect_to @room_offer
    else
      render 'new'
    end
  end

  def update
    @room_offer = RoomOffer.find(params[:id])

    if @room_offer.update(room_offer_params)
      redirect_to @room_offer
    else
      render 'edit'
    end
  end

  def destroy
    @room_offer = RoomOffer.find(params[:id])
    @room_offer.destroy

    redirect_to room_offers_path
  end

  private
    def room_offer_params
      params.require(:room_offer).permit(:slogan, :room_description, :total_area)
    end

end
