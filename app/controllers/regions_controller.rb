class RegionsController < ApplicationController

  def index
    remember_region if !current_user
  end

  def locations
    if params[:category].present?
      @category = LocationCategory.find_by(slug: params[:category])
      @special_category = params[:category] if helpers.special_categories.include?(params[:category])
    end
  end

  def meetings
    if params[:category].present?
      @category = EventCategory.find_by(slug: params[:category])
      @special_category = params[:category] if helpers.special_categories.include?(params[:category])
    end
  end

  def rooms
    if params[:category].present?
      @category = RoomCategory.find_by(slug: params[:category])
      @special_category = params[:category] if helpers.special_categories.include?(params[:category])
    end
  end

  def tools
    if params[:category].present?
      @category = ToolCategory.find_by(slug: params[:category])
    end
  end

  def groups
    @featured_groups = Group.in(current_region).featured.include_for_box
    @category = GroupCategory.find_by(id: params[:category])
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
  end

  def zuckerls
  end

  def platform_meetings
    @meeting_category = MeetingCategory.find_by(id: params[:category])
  end
end
