class LocationsController < ApplicationController
  include AddressUtilities
  
  prepend_before_action :set_graetzl
  before_filter :set_location, only: [:show, :edit, :update]
  before_filter :authenticate_user!
  before_filter :authorize_user!, except: [:index, :show]

  def new
    get_address(check_for_adopt) if request.post?
    @location = @graetzl.locations.build(address_attributes: session[:address])
    @location.build_contact
    empty_session
  end

  def create
    @location = @graetzl.locations.build(location_params)
    if @location.pending!
      enqueue_and_redirect
    else
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
    if !@location.managed? && @location.pending!
      enqueue_and_redirect
    elsif @location.managed? && @location.save
      redirect_to [@location.graetzl, @location]
    else
      render :edit
    end
  end

  def index
    @locations = @graetzl.locations.available
  end

  def show
    @meetings = @location.meetings.upcoming
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

    def enqueue_and_redirect
      flash[:notice] = 'Deine Locationanfrage wird geprüft. Du erhältst eine Nachricht sobald sie bereit ist.'
      redirect_to @graetzl      
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
            :coordinates],
          category_ids: []).
        merge(user_ids: [current_user.id])
    end

    def check_for_adopt
      puts 'CALLING CHECK FOR ADOPT'
      return Proc.new do |address|
        puts 'CALLING CHECK FOR ADOPT CALLBACK'
        @graetzl = address.graetzl || @graetzl
        @locations = address.available_locations        
        render :adopt unless @locations.empty?
      end
    end


end
