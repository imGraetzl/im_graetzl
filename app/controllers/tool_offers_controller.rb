class ToolOffersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :calculate_price]

  def show
    @tool_offer = ToolOffer.in(current_region).non_deleted.find(params[:id])
    @comments = @tool_offer.comments.includes(:user, :images).order(created_at: :desc)
  end

  def select
  end

  def new
    @tool_offer = ToolOffer.new(current_user.slice(:first_name, :last_name, :iban))
  end

  def create
    @tool_offer = ToolOffer.new(tool_offer_params)
    @tool_offer.user_id = current_user.id
    @tool_offer.region_id = current_region.id

    if @tool_offer.save
      ToolMailer.tool_offer_published(@tool_offer).deliver_later
      ActionProcessor.track(@tool_offer, :create)
      redirect_to @tool_offer
    else
      render 'new'
    end
  end

  def edit
    @tool_offer = current_user.tool_offers.non_deleted.find(params[:id])
  end

  def update
    @tool_offer = current_user.tool_offers.non_deleted.find(params[:id])
    @tool_offer.assign_attributes(tool_offer_params)

    if @tool_offer.save
      redirect_to @tool_offer
    else
      render 'edit'
    end
  end

  def update_status
    @tool_offer = current_user.tool_offers.non_deleted.find(params[:id])
    @tool_offer.update(status: params[:status])
    redirect_back(fallback_location: tools_user_path)
  end

  def calculate_price
    @tool_offer = ToolOffer.find(params[:id])
    @tool_rental = @tool_offer.tool_rentals.build(params.permit(:rent_from, :rent_to))
    head :bad_request and return if @tool_rental.rent_from.blank? || @tool_rental.rent_to.blank?
    @tool_rental.calculate_price
  end

  def destroy
    @tool_offer = current_user.tool_offers.find(params[:id])
    @tool_offer.deleted!
    redirect_to tools_user_path
  end

  private

  def tool_offer_params
    params.require(:tool_offer).permit(
      :title, :description, :brand, :model, :status, :keyword_list,
      :value_up_to, :serial_number, :known_defects, :deposit,
      :price_per_day, :two_day_discount, :weekly_discount,
      :tool_category_id, :location_id,
      :graetzl_id, :address_street, :address_coords, :address_city, :address_zip, :address_description,
      :cover_photo, :remove_cover_photo,
      :first_name, :last_name, :iban,
      images_attributes: [:id, :file, :_destroy],
    )
  end

end
