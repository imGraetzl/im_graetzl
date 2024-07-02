class CrowdBoostsController < ApplicationController
  layout :set_layout
  before_action :authenticate_user!, except: [:show, :index, :charges, :campaigns, :call]

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
    flash.now[:alert] = "Dieser Topf ist aktuell inaktiv." if @crowd_boost.disabled?
  end

  def call
    @crowd_boost = CrowdBoost.find(params[:id])
    @next_slot = @crowd_boost.next_slot(current_region)
    @remaining_days = (Date.new(2024, 8, 1) - Date.today).to_i
  end

  def charges
    @crowd_boost = CrowdBoost.find(params[:id])
    @charges = @crowd_boost.crowd_boost_charges.debited.order(created_at: :desc)
  end

  def campaigns
    @crowd_boost = CrowdBoost.find(params[:id])
    @campaigns = @crowd_boost.crowd_campaigns.boost_initialized.by_currentness
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
