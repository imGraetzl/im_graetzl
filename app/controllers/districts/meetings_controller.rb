class Districts::MeetingsController < ApplicationController

  # Overwrite to match needed js
  def self.controller_name
    'districts'
  end

  def index
    @district = District.find(params[:district_id])
    if request.xhr?
      @scope = params[:scope]
      @meetings = @district.meetings.
                            basic.
                            send(@scope).
                            page(params[@scope.to_sym]).
                            per(@scope == 'past' ? 6 : 8)
    else
      @upcoming = @district.meetings.basic.upcoming.page(params[:upcoming]).per(8)
      @past = @district.meetings.basic.past.page(params[:past]).per(6)
      @map_data = GeoJSONService.call(districts: @district, graetzls: @district.graetzls)
    end
  end
end
