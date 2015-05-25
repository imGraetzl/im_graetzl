class DistrictsController < ApplicationController
  def index
    @districts = District.all
    @meetings = Meeting.limit(4)
  end

  def show
    @district = District.find(params[:id])
    @meetings = @district.graetzls.collect(&:meetings).flatten.uniq.take(4)
  end
end