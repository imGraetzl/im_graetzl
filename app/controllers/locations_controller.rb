class LocationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @locations = collection_scope.in(current_region).approved.include_for_box
    @locations = filter_collections(@locations)
    @locations = @locations.order("last_activity_at DESC").page(params[:page]).per(params[:per_page] || 15)
  end

  def show
    @location = Location.in(current_region).find(params[:id])
    redirect_enqueued and return if @location.pending?

    @graetzl = @location.graetzl
    @posts = @location.location_posts.includes(:images, :comments).order(created_at: :desc).first(20)
    @zuckerls = @location.zuckerls.live
    @room_offer = RoomOffer.where(location_id: @location).last
    @room_demand = RoomDemand.where(location_id: @location).last
  end

  def new
    @location = current_user.locations.build(location_category_id: current_user.location_category_id)
    @location.graetzl = user_home_graetzl
  end

  def create
    @location = Location.new(location_params)
    @location.clear_address if params[:no_address] == 'true'
    @location.user = current_user
    @location.region_id = current_region.id

    if @location.save
      redirect_enqueued
    else
      render :new
    end
  end

  def edit
    @location = fetch_user_location(params[:id])
  end

  def update
    @location = fetch_user_location(params[:id])
    @location.assign_attributes(location_params)
    @location.clear_address if params[:no_address] == 'true'
    if @location.save
      redirect_to [@location.graetzl, @location]
    else
      render :edit
    end
  end

  def add_post
    @location = fetch_user_location(params[:id])
    @location_post = @location.location_posts.build(location_post_params)
    if @location_post.save
      ActionProcessor.track(@location, :post, @location_post)
    end
    render 'locations/location_posts/add'
  end

  def remove_post
    @location = fetch_user_location(params[:id])
    @location_post = @location.location_posts.find(params[:post_id])
    @location_post.destroy
    render 'locations/location_posts/remove'
  end

  def comment_post
    @location = Location.find(params[:id])
    @location_post = @location.location_posts.find(params[:post_id])
    @comment = @location_post.comments.new(location_comment_params)
    @comment.user = current_user
    if @comment.save
      ActionProcessor.track(@location, :comment, @comment)
    end
    render 'locations/location_posts/comment'
  end

  def destroy
    @location = fetch_user_location(params[:id])
    @location.destroy
    redirect_to locations_user_path, notice: 'Location entfernt'
  end

  def tooltip
    head :ok and return if browser.bot? && !request.format.js?
    @location = Location.in(current_region).find(params[:id])
    @user = @location.user
    render layout: false
  end

  private

  def collection_scope
    if params[:graetzl_id].present?
      graetzl = Graetzl.find(params[:graetzl_id])
      Location.where(graetzl: graetzl)
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
      user.locations
    else
      Location.all
    end
  end

  def filter_collections(locations)
    graetzl_ids = params.dig(:filter, :graetzl_ids)

    if params[:special_category_id].present? && params[:special_category_id] == 'online-shops'
      locations = locations.online_shop
      graetzl_ids = [] # Reset and always show Online Shops from ALL Dsirticts
    elsif params[:category_id].present?
      locations = locations.where(location_category: params[:category_id])
    end

    if graetzl_ids.present? && graetzl_ids.any?(&:present?)
      locations = locations.where(graetzl_id: graetzl_ids)
    end

    locations
  end

  def fetch_user_location(id)
    current_user.locations.find(id)
  end

  def redirect_enqueued
    redirect_to root_url, notice: 'Deine Schaufenster-Anfrage wird geprüft. Du erhältst eine Nachricht sobald sie bereit ist.'
  end

  def location_params
    params.require(:location).permit(
      :name, :graetzl_id, :slogan, :description, :avatar, :remove_avatar, :cover_photo, :remove_cover_photo,
      :address_street, :address_coords, :address_city, :address_zip, :address_description,
      :location_category_id, :product_list, :website_url, :online_shop_url, :email, :phone, :open_hours,
    )
  end

  def location_post_params
    params.require(:location_post).permit(
      :title, :content, images_attributes: [:id, :file, :destroy]
    )
  end

  def location_comment_params
    params.require(:comment).permit(
      :content,
      images_attributes: [:file],
    )
  end

end
