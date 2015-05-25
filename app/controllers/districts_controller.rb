class DistrictsController < ApplicationController
  def index
    @districts = District.all
    @meetings = Meeting.all
  end

  def show
    @district = District.find(params[:id])
    @meetings = @district.graetzls.collect(&:meetings).flatten.uniq
    #@meetings_with_graetzl = @district.graetzls.collect{ |g| [g.id, g.meetings.flatten] }
  end
end



#Meeting.all.collect{|g| g.graetzls.pluck(:id)}.uniq
#District.find_by_zip('1150').graetzls.collect{|g| g.meetings.pluck(:id)}.uniq