class Locations::MeetingsController < MeetingsController
  def new
    @parent = find_location
    @meeting = @parent.build_meeting_for current_user
  end

  def create
    @parent = find_location
    super
  end

  private

  def find_location
    Location.find params[:location_id]
  end
end
