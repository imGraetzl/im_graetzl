class Districts::MeetingsController < ApplicationController
  include DistrictContext

  def index
    @district = District.find(params[:district_id])
    if request.xhr?
      @scope = params[:scope].to_sym
      @meetings = paginate_index @scope
    else
      @upcoming = @district.meetings.basic.upcoming.paginate_with_padding(params[:upcoming] || 1)
      @past = @district.meetings.basic.past.page(params[:past]).per(6)
      @map_data = GeoJSONService.call(districts: @district, graetzls: @district.graetzls)
    end
  end

  private

  def paginate_index(scope)
    case scope
    when :upcoming
      @district.meetings.basic.upcoming.paginate_with_padding(params[scope] || 1)
    when :past
      @district.meetings.basic.past.page(params[scope]).per(6)
    end
  end
end
