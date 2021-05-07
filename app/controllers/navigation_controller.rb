class NavigationController < ApplicationController
  before_action :authenticate_user!

  def load_content
    @type = params[:type]
    case @type
    when 'locations'
      @locations = current_user.locations.approved.first(5)
    when 'meetings'
      @meetings = current_user.attended_meetings.upcoming.first(6)
    when 'rooms'
      @room_offers = current_user.room_offers.first(2)
      @room_demands = current_user.room_demands.first(2)
    when 'tools'
      @tool_offers = current_user.tool_offers.non_deleted.first(4)
    when 'groups'
      @groups = current_user.groups.last(6).reverse
    end
  end

end
