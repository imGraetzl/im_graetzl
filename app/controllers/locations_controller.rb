class LocationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_location, except: [:index, :new, :create]
  include GraetzlChild

  def index
    @locations = @graetzl.locations
                          .approved
                          .includes(:address, :category)
                          .paginate_index(params[:page] || 1)
  end

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

  # TODO refactor this into separate methods
  def show
    if request.xhr?
      paginate_ajax(@location)
    else
      if @location.pending?
        enqueue_and_redirect(:back)
      else
        verify_graetzl_child(@location)
        @meetings_upcoming = @location.meetings.basic.upcoming.includes(:graetzl).page(1).per(2)
        @meetings_past = @location.meetings.basic.past.includes(:graetzl).page(1).per(2)
        @posts = @location.posts.page(1).per(10)
      end
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

  # TODO: extract into concern
  def paginate_ajax(parent)
    case @scope = params[:scope].to_sym
    when :posts
      @posts = @location.posts.page(params[:page]).per(10)
    else
      @meetings = parent.meetings.basic.send(@scope).page(params[:page]).per(2)
    end
  end

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
          :phone,
          :hours],
        address_attributes: [
          :id,
          :street_name,
          :street_number,
          :zip,
          :city,
          :_destroy]).
      merge(user_ids: [current_user.id])
  end
end
