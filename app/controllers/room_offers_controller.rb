class RoomOffersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @room_offers = RoomOffer.page(params[:page]).per(15)
  end

  def show
    @room_offer = RoomOffer.find(params[:id])
  end

  def new
    @room_offer = current_user.room_offers.new
    @room_offer.room_offer_prices.build
  end

  def edit
    @room_offer = current_user.room_offers.find(params[:id])
  end

  def create
    @room_offer = current_user.room_offers.new(room_offer_params)
    @room_offer.address = Address.from_feature(params[:feature])
    if @room_offer.save
      redirect_to @room_offer
    else
      render 'new'
    end
  end

  def update
    @room_offer = current_user.room_offers.find(params[:id])
    if @room_offer.update(room_offer_params)
      redirect_to @room_offer
    else
      render 'edit'
    end
  end

  def destroy
    @room_offer = current_user.room_offers.find(params[:id])
    @room_offer.destroy

    redirect_to room_offers_path
  end

  private

  def room_offer_params
    params
      .require(:room_offer)
      .permit(
        :slogan,
        :rented_area,
        :total_area,
        :room_description,
        :owner_description,
        :tenant_description,
        :wants_collaboration,
        :cover_photo,
        :remove_cover_photo,
        address_attributes: [
          :id, :street_name, :street_number, :zip, :city
        ],
        room_offer_prices_attributes: [
          :id, :name, :amount, :_destroy
        ],
        room_category_ids: []
    ).merge(
      keyword_list: [params[:suggested_keywords], params[:custom_keywords]].join(", ")
    )
  end
end
