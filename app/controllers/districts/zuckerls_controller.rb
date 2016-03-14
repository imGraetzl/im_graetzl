class Districts::ZuckerlsController < ApplicationController
  include DistrictContext

  def index
    set_district
    set_map_data unless request.xhr?
    @zuckerls = @district.zuckerls.
      page(params[:page]).per(15)
  end
end
