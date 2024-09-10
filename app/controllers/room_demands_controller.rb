class RoomDemandsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :reactivate]

  def show
    @room_demand = RoomDemand.find(params[:id])
    redirect_to_region?(@room_demand)
    @comments = @room_demand.comments.includes(:user, :images).order(created_at: :desc)
  end

  def new
    @room_demand = RoomDemand.new
    @room_demand.assign_attributes(current_user.slice(:first_name, :last_name, :email, :website))
  end

  def create
    @room_demand = RoomDemand.new(room_demand_params)
    @room_demand.user_id = current_user.admin? ? params[:user_id] : current_user.id
    @room_demand.region_id = current_region.id
    @room_demand.activate

    if @room_demand.save
      RoomMailer.room_demand_published(@room_demand).deliver_later
      ActionProcessor.track(@room_demand, :create)
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
      ActionProcessor.track(@room_demand, :update) if @room_demand.refresh_activity
      redirect_to @room_demand
    else
      render 'edit'
    end
  end

  def update_status
    @room_demand = current_user.room_demands.find(params[:id])
    @room_demand.update(status: params[:status])
    ActionProcessor.track(@room_demand, :update) if @room_demand.refresh_activity
    flash[:notice] = t("activerecord.attributes.room_demand.status_message.#{@room_demand.status}")
    redirect_back(fallback_location: rooms_user_path)
  end

  def reactivate
    @room_demand = RoomDemand.find(params[:id])
    if @room_demand.disabled? && params[:activation_code].to_i == @room_demand.activation_code
      @room_demand.update(status: :enabled)
      ActionProcessor.track(@room_demand, :update) if @room_demand.refresh_activity
      flash[:notice] = "Deine Raumsuche wurde erfolgreich verlängert!"
    elsif @room_demand.enabled?
      flash[:notice] = "Deine Raumsuche ist bereits aktiv."
    else
      flash[:notice] = "Der Aktivierungslink ist leider ungültig. Log dich ein um deinen Raumteiler zu aktivieren."
    end
    redirect_to @room_demand
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
        :entire_region,
        :slogan,
        :needed_area,
        :demand_description,
        :personal_description,
        :tenant_description,
        :wants_collaboration,
        :avatar,
        :activation_code,
        :remove_avatar,
        :last_activated_at,
        :first_name, :last_name, :website, :email, :phone, :location_id,
        room_category_ids: [],
        graetzl_ids: [],
    ).merge(
      keyword_list: [params[:suggested_keywords], params[:custom_keywords]].join(", ")
    )
  end
end
