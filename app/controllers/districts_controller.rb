class DistrictsController < ApplicationController

  # Evtl rausnehmen und vorerst nur rack attack?
  rate_limit to: 60, within: 120.seconds, by: -> { rate_limit_identity }, with: -> { handle_rate_limit!(retry_after: 60) }
  before_action :load_district

  def index
    @activity_sample = ActivitySample.new(district: @district, current_region: current_region)
  end

  def meetings
    if params[:category].present?
      @category = EventCategory.visible.find_by(slug: params[:category])
      @special_category = params[:category] if helpers.special_categories.include?(params[:category])
    end
  end

  def locations
    if params[:category].present?
      @category = LocationCategory.find_by(slug: params[:category])
      @special_category = params[:category] if helpers.special_categories.include?(params[:category])
    end
  end

  def rooms
    if params[:category].present?
      @category = RoomCategory.find_by(slug: params[:category])
      @special_category = params[:category] if helpers.special_categories.include?(params[:category])
    end
  end

  def groups
    @featured_groups = @district.groups.in(current_region).featured.include_for_box
    @category = GroupCategory.find_by(id: params[:category])
  end

  def coop_demands
    if params[:category].present?
      @category = CoopDemandCategory.find_by(slug: params[:category])
    end
  end

  def zuckerls
  end

  private

  def load_district
    @district = District.in(current_region).find(params[:id])
  end

end
