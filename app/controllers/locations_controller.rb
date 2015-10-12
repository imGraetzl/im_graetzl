class LocationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_location, except: [:index, :new, :create]
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
    #puts params
    @location = Location.new(location_params)
    if @location.save
      enqueue_and_redirect(root_url)
    else
      render :new
    end
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
    if @location.pending?
      enqueue_and_redirect(:back)
    else
      verify_graetzl_child(@location)
      @meetings = @location.meetings.basic.upcoming
    end
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

  def enqueue_and_redirect(url)
    flash[:notice] = 'Deine Locationanfrage wird geprüft. Du erhältst eine Nachricht sobald sie bereit ist.'
    redirect_to url
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
        :category_id,
        :meeting_permission,
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
          :_destroy]).
      merge(user_ids: [current_user.id])
  end
end
