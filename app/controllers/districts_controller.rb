class DistrictsController < ApplicationController
  def index
    @districts = District.all()
    @meetings = Meeting.upcoming.limit(4)
  end

  def show
    @district = District.find(params[:id])
    @meetings = Meeting.upcoming.where(graetzl: @district.graetzls).limit(4)
  end
end