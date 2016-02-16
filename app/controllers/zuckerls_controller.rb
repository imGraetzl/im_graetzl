class ZuckerlsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def new
    set_location or return

  end

  def index
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
end
