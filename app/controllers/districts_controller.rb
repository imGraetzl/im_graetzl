class DistrictsController < ApplicationController
  before_action :load_district

  def show
    @activity_sample = ActivitySample.new(district: @district)
  end

  def graetzls
    render json: District.memoized(@district.id).graetzls.to_json(only: [:id, :name])
  end

  def meetings
    if params[:category].present?
      @category = EventCategory.find_by(slug: params[:category])
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

  def tool_offers
    if params[:category].present?
      @category = ToolCategory.find_by(slug: params[:category])
    end
  end

  def groups
    @featured_groups = @district.groups.featured.include_for_box
    @category = GroupCategory.find_by(id: params[:category])
  end

  def zuckerls
  end

  private

  def load_district
    @district = District.find(params[:id])
  end

end
