class Districts::MeetingsController < ApplicationController

  # Overwrite to match needed js
  def self.controller_name
    'districts'
  end

  def index
    @district = District.find(params[:district_id])
    if request.xhr?
      @page_param = params.keys.select { |k| k.to_s.match(/page_/) }.first #:past_page
      @scope = @page_param.gsub 'page_', ''
      @meetings = @district.meetings.
                            basic.
                            send(@scope).
                            page(params[@page_param]).
                            per(@scope == 'past' ? 3 : 6)
    else
      @upcoming = @district.meetings.basic.upcoming.page(params[:page_upcoming]).per(6)
      @past = @district.meetings.basic.past.page(params[:page_past]).per(3)
      @map_data = GeoJSONService.call(districts: @district, graetzls: @district.graetzls)
    end
  end
end
