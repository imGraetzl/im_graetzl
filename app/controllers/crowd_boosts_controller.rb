class CrowdBoostsController < ApplicationController
  layout :set_layout
  before_action :authenticate_user!, except: [:show, :index]

  def index
    if current_region
      @crowd_boosts = CrowdBoost.enabled.in(current_region)
    else
      @crowd_boosts = CrowdBoost.enabled.all
    end
  end

  def show
    @crowd_boost = CrowdBoost.find(params[:id])
    @next_slot = @crowd_boost.next_slot(current_region)
  end

  private

  def set_layout
    if current_region.nil?
      'platform'
    else
      'application'
    end
  end

end
