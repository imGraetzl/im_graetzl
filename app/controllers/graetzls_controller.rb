class GraetzlsController < ApplicationController
  before_action :load_graetzl

  def show
    @activity_sample = ActivitySample.new(graetzl: @graetzl) if !user_signed_in?
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

  def zuckerls
  end

  def posts
  end

  def tool_offers
    if params[:category].present?
      @category = ToolCategory.find_by(slug: params[:category])
    end
  end

  def groups
    @featured_groups = @graetzl.groups.featured.include_for_box
    @category = GroupCategory.find_by(id: params[:category])
  end

  private

  def load_graetzl
    @graetzl = Graetzl.find(params[:id])
  end

end
