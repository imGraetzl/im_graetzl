class RegionsController < ApplicationController
  before_action :redirect_unless_region, only: %i[
    locations meetings rooms groups coop_demands
    crowd_campaigns energies polls zuckerls
  ]

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
      @category = EventCategory.visible.find_by(slug: params[:category])
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
    # Featured Crowdfunding Meetings
    @meeting = Meeting.crowdfunding.in(current_region).first
  end

  def energies
  end

  def polls
  end

  def zuckerls
  end

  private

  def redirect_unless_region
    return if current_region

    if action_name.to_sym == :crowd_campaigns
      redirect_to start_crowd_campaigns_path, status: :moved_permanently
    else
      redirect_to about_platform_path, status: :moved_permanently
    end
  end

end
