class Locations::MeetingsController < MeetingsController
  def new
    @parent = Location.find params[:location_id]
    @meeting = @parent.meetings.build(graetzl_id: @parent.graetzl.id)
    # TODO: add address only if user is owner of location?
  end
end
