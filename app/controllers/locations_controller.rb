class LocationsController < ApplicationController
  before_filter :set_graetzl
  before_filter :set_location, only: [:show, :edit, :update]
  before_filter :authenticate_user!
  before_filter :authorize_user!, except: [:index, :show]

  # GET /new/address
  def new_address
  end

  # POST /new/address
  def set_new_address
    address = Address.new(Address.attributes_from_feature(address_params[:feature] || ''))
    session[:address] = address.attributes
    @graetzl = address.graetzl || @graetzl
    @locations = address.available_locations

    if @locations.empty?
      redirect_to new_graetzl_location_path(@graetzl)
    else
      render :adopt
    end
  end

  def new
    @location = @graetzl.locations.build(address_attributes: session[:address] || Address.new.attributes)
    @location.build_contact    
  end

  def create
    empty_session
    @location = @graetzl.locations.build(location_params)
    if @location.pending!
      flash[:notice] = 'Deine Locationanfrage wird geprüft. Du erhältst eine Nachricht sobald sie bereit ist.'
      redirect_to @graetzl
    else
      render :new
    end 
  end

  def edit
    if @location.managed?
      @location.request_ownership(current_user)
      flash[:notice] = 'Deine Anfrage wird geprüft. Du erhältst eine Nachricht sobald sie bereit ist.'
      redirect_to @graetzl
    end
  end

  def update
    @location.attributes = location_params
    if @location.pending!
      flash[:notice] = 'Deine Locationanfrage wird geprüft. Du erhältst eine Nachricht sobald sie bereit ist.'
      redirect_to @graetzl
    else
      render :edit
    end    
  end

  def index
    @locations = @graetzl.locations.available
  end

  def show
  end

  private

    def set_graetzl
      @graetzl = Graetzl.find(params[:graetzl_id])
    end

    def set_location
      @location = @graetzl.locations.find(params[:id])
    end

    def authorize_user!      
      unless current_user.business?
        flash[:error] = 'Nur wirtschaftstreibende User können Locations betreiben.'
        redirect_to @graetzl
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.
        require(:location).
        permit(:name,
          :slogan,
          :description,
          :avatar, :remove_avatar,
          :cover_photo, :remove_cover_photo,
          contact_attributes: [
            :website,
            :email,
            :phone],
          address_attributes: [
            :street_name,
            :street_number,
            :zip,
            :city,
            :coordinates]).
        merge(user_ids: [current_user.id])
    end

    # strong params for address
    def address_params
      params.permit(:address, :feature)
    end

    def empty_session
      session.delete(:address)
    end
end
