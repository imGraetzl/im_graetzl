class LocationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_location, except: [:index, :show, :edit, :new, :create]
  include GraetzlChild

  def new
    if request.get?
      @graetzl = Graetzl.find(params[:graetzl_id] || current_user.graetzl_id)
      @district = @graetzl.districts.first
      render :graetzl_form
    else
      @graetzl = Graetzl.find(params[:graetzl_id])
      @location = @graetzl.locations.build
      @location.build_contact
    end
  end

  def create
    @location = Location.new(location_params)
    if @location.save
      enqueue_and_redirect
    else
      render :new
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    if @location.update(location_params)
      redirect_to [@location.graetzl, @location]
    else
      render :edit
    end
  end

  def index
    @locations = @graetzl.locations.approved.includes(:address)
  end

  def show
    @location = Location.includes(:address, :contact, :location_ownerships, :meetings).find(params[:id])
    verify_graetzl_child(@location)
    @meetings = @location.meetings.basic.upcoming
  end

  def destroy
    if @location.users.include?(current_user) && @location.destroy
      flash[:notice] = 'Location entfernt'
    else
      flash[:error] = 'Nur Betreiber können Locations löschen'
    end
    redirect_to :back
  end


  private

  def set_location
    @location = Location.find(params[:id])
  end

  def enqueue_and_redirect
    flash[:notice] = 'Deine Locationanfrage wird geprüft. Du erhältst eine Nachricht sobald sie bereit ist.'
    redirect_to root_url
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def location_params
    params.
      require(:location).
      permit(:name,
        :graetzl_id,
        :slogan,
        :description,
        :avatar, :remove_avatar,
        :cover_photo, :remove_cover_photo,
        :allow_meetings,
        contact_attributes: [
          :id,
          :website,
          :email,
          :phone],
        address_attributes: [
          :id,
          :street_name,
          :street_number,
          :zip,
          :city,
          :coordinates,
          :_destroy],
        category_ids: []).
      merge(user_ids: [current_user.id])
  end

  def adopt?
    if request.post?
      @locations = @address.available_locations
      return @locations.present?
    end
  end
end
