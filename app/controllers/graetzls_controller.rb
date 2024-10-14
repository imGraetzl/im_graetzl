class GraetzlsController < ApplicationController
  before_action :load_graetzl

  def show
    @activity_sample = ActivitySample.new(graetzl: @graetzl, current_region: current_region) if !user_signed_in?
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

  def coop_demands
    if params[:category].present?
      @category = CoopDemandCategory.find_by(slug: params[:category])
    end
  end

  def crowd_campaigns
    if params[:category].present?
      @category = CrowdCategory.find_by(slug: params[:category])
    end
    # Featured Crowdfunding Meetings
    @meeting = Meeting.crowdfunding.in(current_region).first
  end

  def zuckerls
  end

  def posts
  end

  def tools
    if params[:category].present?
      @category = ToolCategory.find_by(slug: params[:category])
    end
  end

  def groups
    @featured_groups = @graetzl.groups.in(current_region).featured.include_for_box
    @category = GroupCategory.find_by(id: params[:category])
  end

  private

  def load_graetzl
    head :not_found and return if current_region.nil?
    #redirect_to about_platform_path, and return if current_region.nil?
    @graetzl = Graetzl.in(current_region).find(params[:id])
  end

end
