class DistrictsController < ApplicationController
  def index
    @districts = District.all
  end

  def show
    @district = District.find(params[:id])
  end
end
