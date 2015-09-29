class LocationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_location, except: [:index, :new, :create]
  #include GraetzlBeforeNew
  include GraetzlChild

  def new
    if request.get?
      render :graetzl_form
    else
      @graetzl = Graetzl.find(params[:graetzl_id])
      #@location = @graetzl.locations.build(address_attributes: session[:address])
      @location = @graetzl.locations.build
      @location.build_contact
    end
  end

  def create
    @location = Location.new(location_params)
    begin
      @location.pending!
      enqueue_and_redirect
    rescue ActiveRecord::RecordInvalid => invalid
      render :new
    end
  end

  def edit
    if @location.managed? && !@location.owned_by(current_user)
      @location.request_ownership(current_user)
      enqueue_and_redirect
    end
  end

  def update
    @location.attributes = location_params
    begin
      if !@location.managed? && @location.pending!
        enqueue_and_redirect
      elsif @location.managed? && @location.save
        redirect_to [@location.graetzl, @location]
      else
        render :edit
      end
    rescue ActiveRecord::RecordInvalid => invalid
      render :edit
    end
  end

  def index
    #@locations = @graetzl.locations.available
    @locations = @graetzl.locations.managed.includes(:address)
  end

  def show
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
        contact_attributes: [
          :website,
          :email,
          :phone],
        address_attributes: [
          :street_name,
          :street_number,
          :zip,
          :city,
          :coordinates],
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
