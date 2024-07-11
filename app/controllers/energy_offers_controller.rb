class EnergyOffersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :reactivate]

  def show
    @energy_offer = EnergyOffer.find(params[:id])
    redirect_to_region?(@energy_offer)
    @comments = @energy_offer.comments.includes(:user, :images).order(created_at: :desc)
  end

  def select
  end

  def new
    @energy_offer = EnergyOffer.new(current_user_address_params)
  end

  def create
    @energy_offer = EnergyOffer.new(energy_offer_params)
    @energy_offer.user_id = current_user.admin? ? params[:user_id] : current_user.id
    @energy_offer.region_id = current_region.id
    @energy_offer.activate

    if @energy_offer.save
      ActionProcessor.track(@energy_offer, :create)
      redirect_to @energy_offer
    else
      render 'new'
    end
  end

  def edit
    @energy_offer = current_user.energy_offers.find(params[:id])
  end

  def update
    @energy_offer = current_user.energy_offers.find(params[:id])
    if @energy_offer.update(energy_offer_params)
      ActionProcessor.track(@energy_offer, :update) if @energy_offer.refresh_activity
      redirect_to @energy_offer
    else
      render 'edit'
    end
  end

  def update_status
    @energy_offer = current_user.energy_offers.find(params[:id])
    @energy_offer.update(status: params[:status])
    ActionProcessor.track(@energy_offer, :update) if @energy_offer.refresh_activity
    flash[:notice] = t("activerecord.attributes.energy_offer.status_message.#{@energy_offer.status}")
    redirect_back(fallback_location: energies_user_path)
  end

  def reactivate
    @energy_offer = EnergyOffer.find(params[:id])
    if @energy_offer.disabled? && params[:activation_code].to_i == @energy_offer.activation_code
      @energy_offer.update(status: :enabled)
      ActionProcessor.track(@energy_offer, :update) if @energy_offer.refresh_activity
      flash[:notice] = "Dein Raumteiler wurde erfolgreich verlängert!"
    elsif @energy_offer.enabled?
      flash[:notice] = "Dein Raumteiler ist bereits aktiv."
    else
      flash[:notice] = "Der Aktivierungslink ist leider ungültig. Log dich ein um deinen Raumteiler zu aktivieren."
    end
    redirect_to @energy_offer
  end

  def destroy
    @energy_offer = current_user.energy_offers.find(params[:id])
    @energy_offer.destroy
    redirect_to energies_user_path
  end

  private

  def current_user_address_params
    {
      contact_email: current_user.email,
      contact_website: current_user.website,
      contact_name: current_user.billing_address&.full_name || current_user.full_name,
      contact_company: current_user.billing_address&.company,
      contact_address: current_user.billing_address&.street || current_user.address_street,
      contact_zip: current_user.billing_address&.zip || current_user.address_zip,
      contact_city: current_user.billing_address&.city || current_user.address_city,
    }
  end

  def energy_offer_params
    params
      .require(:energy_offer)
      .permit(
        :energy_type,
        :operation_state,
        :organization_form,
        :title,
        :description,
        :project_goals,
        :special_orientation,
        :producer_price_per_kwh,
        :consumer_price_per_kwh,
        :members_count,
        :goal_producer_solarpower,
        :goal_prosumer_solarpower,
        :goal_producer_hydropower,
        :goal_prosumer_hydropower,
        :goal_producer_windpower,
        :goal_prosumer_windpower,
        :goal_roofspace,
        :goal_freespace,
        :cover_photo,
        :remove_cover_photo,
        :avatar,
        :activation_code,
        :remove_avatar,
        :last_activated_at,
        :graetzl_id,
        :location_id,
        :address_street, :address_coords, :address_city, :address_zip, :address_description,
        :contact_company, :contact_name, :contact_address, :contact_zip, :contact_city, :contact_website, :contact_email, :contact_phone,
        images_attributes: [:id, :file, :_destroy],
        energy_category_ids: [],
        graetzl_ids: [],
    )
  end

end
