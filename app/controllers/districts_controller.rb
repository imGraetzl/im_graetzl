class DistrictsController < ApplicationController
  def index
    @districts = District.all
    upcoming = Meeting.where(starts_at_date: nil).concat(Meeting.where('starts_at_date > ?', Date.yesterday)).map(&:id)
    @meetings = Meeting.where(id: upcoming).take(4)
  end

  def show
    @district = District.find(params[:id])
    upcoming = Meeting.where(starts_at_date: nil).concat(Meeting.where('starts_at_date > ?', Date.yesterday)).map(&:id)
    @meetings = Meeting.where(id: upcoming)
                        .where(graetzl: @district.graetzls)
                        .take(4)
  end
end