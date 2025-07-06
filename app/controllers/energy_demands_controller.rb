class EnergyDemandsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def show
    @energy_demand = EnergyDemand.find(params[:id])
    return if redirect_to_region?(@energy_demand)
    @comments = @energy_demand.comments.includes(:user, :images, comments: [:user, :images]).order(created_at: :desc)
  end

  def new
    @energy_demand = EnergyDemand.new(current_user_address_params)
    @energy_demand.graetzls = [user_home_graetzl] + current_user.favorite_graetzls if user_home_graetzl
  end

  def create
    @energy_demand = EnergyDemand.new(energy_demand_params)
    @energy_demand.user_id = current_user.admin? ? params[:user_id] : current_user.id
    @energy_demand.region_id = current_region.id
    @energy_demand.activate

    if @energy_demand.save
      ActionProcessor.track(@energy_demand, :create)
      redirect_to @energy_demand
    else
      render 'new'
    end
  end

  def edit
    @energy_demand = current_user.energy_demands.find(params[:id])
  end

  def update
    @energy_demand = current_user.energy_demands.find(params[:id])
    if @energy_demand.update(energy_demand_params)
      ActionProcessor.track(@energy_demand, :update) if @energy_demand.refresh_activity
      redirect_to @energy_demand
    else
      render 'edit'
    end
  end

  def update_status
    @energy_demand = current_user.energy_demands.find(params[:id])
    @energy_demand.update(status: params[:status])
    ActionProcessor.track(@energy_demand, :update) if @energy_demand.refresh_activity
    flash[:notice] = t("activerecord.attributes.energy_demand.status_message.#{@energy_demand.status}")
    redirect_back(fallback_location: energies_user_path)
  end

  def destroy
    @energy_demand = current_user.energy_demands.find(params[:id])
    @energy_demand.destroy
    redirect_to energies_user_path
  end

  private

  def current_user_address_params
    {
      contact_email: current_user.email,
      contact_website: current_user.website,
      contact_name: current_user.billing_address&.full_name || current_user.full_name,
      contact_address: current_user.billing_address&.street || current_user.address_street,
      contact_zip: current_user.billing_address&.zip || current_user.address_zip,
      contact_city: current_user.billing_address&.city || current_user.address_city,
    }
  end

  def energy_demand_params
    params
      .require(:energy_demand)
      .permit(
        :energy_type,
        :organization_form,
        :orientation_type,
        :title,
        :description,
        :goal_producer_solarpower,
        :goal_prosumer_solarpower,
        :goal_producer_hydropower,
        :goal_prosumer_hydropower,
        :goal_producer_windpower,
        :goal_prosumer_windpower,
        :goal_roofspace,
        :goal_freespace,
        :avatar,
        :remove_avatar,
        :last_activated_at,
        :graetzl_id,
        :address_street, :address_coords, :address_city, :address_zip, :address_description,
        :contact_company, :contact_name, :contact_address, :contact_zip, :contact_city, :contact_website, :contact_email, :contact_phone,
        energy_category_ids: [],
        graetzl_ids: [],
    )
  end

end
