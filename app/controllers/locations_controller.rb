class LocationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_location, except: [:index, :new, :create]
  include GraetzlChild

  def index
    @locations = Kaminari.paginate_array(
      @graetzl.locations.approved.includes(:posts, :meetings).
        order('posts.created_at DESC NULLS LAST').
        order('meetings.created_at DESC NULLS LAST').
        order(created_at: :desc)
      ).page(params[:page]).per(15)
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

  def show
    @posts = @location.posts.order(created_at: :desc).
      page(params[:page]).per(10)
  end

  # def show
  #   if request.xhr?
  #     @new_content = paginate_show(@scope = params[:scope].to_sym)
  #   else
  #     if @location.pending?
  #       enqueue_and_redirect(:back)
  #     else
  #       verify_graetzl_child(@location)
  #       @upcoming = @location.meetings.basic.upcoming.includes(:graetzl).page(params[:upcoming]).per(2)
  #       @past = @location.meetings.basic.past.includes(:graetzl).page(params[:past]).per(2)
  #       @posts = @location.posts.includes(:graetzl, :images, :author, comments: [:images, :user]).page(params[:page]).per(10)
  #     end
  #   end
  # end

  def destroy
    if @location.users.include?(current_user) && @location.destroy
      flash[:notice] = 'Location entfernt'
    else
      flash[:error] = 'Nur Betreiber können Locations löschen'
    end
    redirect_to :back
  end

  private

  def paginate_show(scope)
    case scope
    when :posts
      @location.posts.includes(:graetzl, :images, :author).page(params[:page]).per(10)
    when :upcoming
      @location.meetings.basic.upcoming.includes(:graetzl).page(params[scope]).per(2)
    when :past
      @location.meetings.basic.past.includes(:graetzl).page(params[scope]).per(2)
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
        :product_list,
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
