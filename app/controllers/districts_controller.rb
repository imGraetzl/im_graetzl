class DistrictsController < ApplicationController

  rate_limit to: 10, within: 60.seconds, with: -> { rate_limited! }

  def rate_limited!
    # Log an Sentry
    Sentry.capture_message(
      "Rate limit hit",
      level: :warning,
      extra: {
        ip: request.remote_ip,
        path: request.fullpath,
        ua: request.user_agent
      }
    )

    # Optionale Info in dein normales Rails-Log
    Rails.logger.warn("[RateLimit] ip=#{request.remote_ip} path=#{request.fullpath} ua=#{request.user_agent}")

    response.set_header('Retry-After', '60')
    head :too_many_requests
  end

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
