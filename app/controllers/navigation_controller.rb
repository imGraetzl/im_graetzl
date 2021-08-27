class NavigationController < ApplicationController
  before_action :authenticate_user!

  def load_content
    @type = params[:type]
    case @type
    when 'locations'
      @locations = current_user.locations.in(current_region).approved.first(6)
    when 'zuckerls'
      @zuckerls = Zuckerl.where(location: current_user.locations).in(current_region).where.not(aasm_state: :expired).where.not(aasm_state: :cancelled).order(created_at: :desc).first(6)
    when 'meetings'
      @meetings = current_user.attended_meetings.in(current_region).upcoming.first(6)
    when 'rooms'
      @room_offers = current_user.room_offers.in(current_region).first(3)
      @room_demands = current_user.room_demands.in(current_region).first(3)
    when 'tools'
      @tool_offers = current_user.tool_offers.in(current_region).non_deleted.first(6)
    when 'coop_demands'
      @coop_demands = current_user.coop_demands.in(current_region).first(6)
    when 'groups'
      @groups = current_user.groups.in(current_region).last(6).reverse
    end
  end

end
