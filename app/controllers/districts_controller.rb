class DistrictsController < ApplicationController

  def show
    @district = District.find(params[:id])
    @map_data = MapData.call district: @district, graetzls: @district.graetzls
    @meetings = @district.meetings.include_for_box.by_currentness.first(2)
    @locations = @district.locations.approved.include_for_box.by_activity.first(2)
    @rooms = RoomOffer.where(district_id: @district).first(2)
    # maybe add a random demand too:
    # RoomDemand.includes(:graetzls).where(graetzls: {id: @district.graetzl_ids})
    @zuckerls = @district.zuckerls.order("RANDOM()").first(2)
  end

  def graetzls
    @district = District.find(params[:id])
    render json: @district.graetzls.to_json(only: [:id, :name])
  end

  def meetings
    @district = District.find(params[:id])
    @map_data = MapData.call district: @district, graetzls: @district.graetzls
  end

  def locations
    @district = District.find(params[:id])
    @map_data = MapData.call district: @district, graetzls: @district.graetzls
  end

  def rooms
    @district = District.find(params[:id])
    @map_data = MapData.call district: @district, graetzls: @district.graetzls
  end

  def zuckerls
    @district = District.find(params[:id])
    @map_data = MapData.call district: @district, graetzls: @district.graetzls
  end

end
