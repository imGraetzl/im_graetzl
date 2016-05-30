class Locations::MeetingsController < MeetingsController
  def new
    @parent = get_location
    @meeting = @parent.meetings.build(graetzl_id: @parent.graetzl.id)
    # TODO: add address only if user is owner of location?
    # @meeting.build_address @parent.address.try(:attributes)
  end

  def create
    @parent = get_location
    super
  end

  private

  def get_location
    Location.find params[:location_id]
  end
end
