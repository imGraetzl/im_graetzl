class DistrictsController < ApplicationController
  def index
    @districts = District.all()
    @meetings = Meeting.where(starts_at_date: [nil, Date.yesterday..Date.yesterday.next_year]).limit(4)
  end

  def show
    @district = District.find(params[:id])
    @meetings = Meeting.where(graetzl: @district.graetzls,
                starts_at_date: [nil, Date.yesterday..Date.yesterday.next_year]).limit(4)
  end
end