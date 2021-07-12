class RegionsController < ApplicationController

  def show
    @districts = District.order(zip: :asc)
  end

  def visit_graetzl
    resolver = AddressResolver.from_json(params[:feature])
    if resolver.valid? && resolver.graetzl.present?
      redirect_to resolver.graetzl
    else
      redirect_to region_url
    end
  end

  def locations
    @districts = District.order(zip: :asc)
    if params[:category].present?
      @category = LocationCategory.find_by(slug: params[:category])
      @special_category = params[:category] if helpers.special_categories.include?(params[:category])
    end
  end

  def meetings
    @districts = District.order(zip: :asc)
    if params[:category].present?
      @category = EventCategory.find_by(slug: params[:category])
      @special_category = params[:category] if helpers.special_categories.include?(params[:category])
    end
  end

  def category_meetings

  end

  def rooms
    @districts = District.order(zip: :asc)
    if params[:category].present?
      @category = RoomCategory.find_by(slug: params[:category])
      @special_category = params[:category] if helpers.special_categories.include?(params[:category])
    end
  end

  def groups
    @featured_groups = Group.in(current_region).featured.include_for_box
    @category = GroupCategory.find_by(id: params[:category])
    @districts = District.order(zip: :asc)
  end

  def tool_offers
    @districts = District.order(zip: :asc)
    if params[:category].present?
      @category = ToolCategory.find_by(slug: params[:category])
    end
  end

  def zuckerls
    @districts = District.order(zip: :asc)
  end

  def platform_meetings
    @meeting_category = MeetingCategory.find_by(id: params[:category])
  end
end
