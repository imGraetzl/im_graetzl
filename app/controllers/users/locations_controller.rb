class Users::LocationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @locations = current_user.locations.includes(:location_ownerships, :graetzl)
  end
end
