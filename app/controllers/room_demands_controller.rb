class RoomDemandsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def show
    @room_demand = RoomDemand.find(params[:id])
    @comments = @room_demand.comments.includes(:user, :images).order(created_at: :desc)
  end

  def new
    @room_demand = RoomDemand.new
    @room_demand.assign_attributes(current_user.slice(:first_name, :last_name, :email, :website))
  end

  def create
    @room_demand = RoomDemand.new(room_demand_params)
    if @room_demand.save
      @room_demand.create_activity(:create, owner: current_user)
      redirect_to @room_demand
    else
      render 'new'
    end
  end

  def edit
    @room_demand = current_user.room_demands.find(params[:id])
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

    redirect_to rooms_user_path
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
        :avatar,
        :remove_avatar,
        :first_name, :last_name, :website, :email, :phone, :location_id,
        room_category_ids: [],
        graetzl_ids: [],
    ).merge(
      user_id: current_user.admin? ? params[:admin][:user_id] : current_user.id,
      keyword_list: [params[:suggested_keywords], params[:custom_keywords]].join(", ")
    )
  end
end
