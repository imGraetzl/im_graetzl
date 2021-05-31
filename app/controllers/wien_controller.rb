class WienController < ApplicationController

  def show
    @districts = District.order(zip: :asc)
  end

  def visit_graetzl
    resolver = AddressResolver.from_json(params[:feature])
    if resolver.valid? && resolver.graetzl.present?
      redirect_to resolver.graetzl
    else
      redirect_to wien_url
    end
  end

  def locations
    @districts = District.order(zip: :asc)
    @category = LocationCategory.find_by(id: params[:category]) if params[:category].present?
    @special_category = params[:special_category] if params[:special_category].present?
  end

  def meetings
    @districts = District.order(zip: :asc)
    @category = EventCategory.find_by(id: params[:category]) if params[:category].present?
    @special_category = params[:special_category] if params[:special_category].present?
  end

  def rooms
    @districts = District.order(zip: :asc)
    @category = RoomCategory.find_by(id: params[:category]) if params[:category].present?
    @special_category = params[:special_category] if params[:special_category].present?
  end

  def groups
    @featured_groups = Group.featured.include_for_box
    @category = GroupCategory.find_by(id: params[:category])
    @districts = District.order(zip: :asc)
  end

  def tool_offers
    @districts = District.order(zip: :asc)
    @category = ToolCategory.find_by(id: params[:category]) if params[:category].present?
  end

  def zuckerls
    @districts = District.order(zip: :asc)
  end

  def platform_meetings
    @meeting_category = MeetingCategory.find_by(id: params[:category])
  end
end
