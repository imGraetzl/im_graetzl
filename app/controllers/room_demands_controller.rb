class RoomDemandsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @room_demands = RoomDemand.page(params[:page]).per(15)
  end

  def show
    @room_demand = RoomDemand.find(params[:id])
  end

  def new
    @room_demand = current_user.room_demands.new
  end

  def edit
    @room_demand = current_user.room_demands.find(params[:id])
  end

  def create
    @room_demand = current_user.room_demands.new(room_demand_params)
    if @room_demand.save
      redirect_to @room_demand
    else
      render 'new'
    end
  end

  def update
    @room_demand = current_user.room_demands.find(params[:id])
    if @room_demand.update(room_demand_params)
      redirect_to @room_demand
    else
      render 'edit'
    end
  end

  def destroy
    @room_demand = current_user.room_demands.find(params[:id])
    @room_demand.destroy

    redirect_to room_demands_path
  end

  private

  def room_demand_params
    params
      .require(:room_demand)
      .permit(
        :demand_type,
        :slogan,
        :needed_area,
        :demand_description,
        :personal_description,
        :tenant_description,
        :wants_collaboration,
        :first_name, :last_name, :website, :email, :phone, :location_id,
        room_category_ids: [],
        graetzl_ids: [],
        district_ids: [],
    ).merge(
      keyword_list: [params[:suggested_keywords], params[:custom_keywords]].join(", ")
    )
  end
end
