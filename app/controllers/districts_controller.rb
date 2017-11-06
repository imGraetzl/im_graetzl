class DistrictsController < ApplicationController

  def show
    set_district
    @meetings = @district.meetings.include_for_box.by_currentness.first(2)
    @locations = @district.locations.approved.include_for_box.by_activity.first(2)
    @rooms = RoomOffer.first(2) # TODO: find random in the district
    @zuckerls = @district.zuckerls.order("RANDOM()").first(2)
    @map_data = MapData.call district: @district, graetzls: @district.graetzls
  end

  def graetzls
    set_district
    render json: @district.graetzls.to_json(only: [:id, :name])
  end

  def rooms
    set_district
    @map_data = MapData.call district: @district

    # TODO: actual Bezirk-listed data here
    room_offers = RoomOffer.all
    room_demands = RoomDemand.all
    @rooms = Kaminari.paginate_array(room_offers + room_demands).page(params[:page]).per(15)
  end

  private

  def set_district
    @district = District.find(params[:id])
  end

end
