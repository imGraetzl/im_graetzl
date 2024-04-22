class CrowdBoostsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def index
    @crowd_boosts = CrowdBoost.in(current_region)
  end

  def show
    @crowd_boost = CrowdBoost.in(current_region).find(params[:id])
  end

  private

end
