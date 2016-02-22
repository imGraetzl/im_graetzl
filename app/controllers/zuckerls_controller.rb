class ZuckerlsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def new
    set_location or return
    @zuckerl = @location.zuckerls.build
  end

  def create
    @location = Location.find(params[:location_id])
    @zuckerl = @location.zuckerls.new zuckerl_params
    if @zuckerl.save
      redirect_to zuckerl_billing_address_path @zuckerl
    else
      render :new
    end
  end

  private

  def set_location
    case
    when params[:location_id].present?
      @location = Location.find(params[:location_id])
    when current_user.locations.approved.count == 1
      @location = current_user.locations.approved.first
    else
      @locations = current_user.locations.approved
      render :new_location and return
    end
  end

  def zuckerl_params
    params.require(:zuckerl).permit(
      :title,
      :description,
      :image,
      :remove_image,
      :initiative_id,
      :flyer)
  end
end
