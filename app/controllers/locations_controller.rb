class LocationsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @locations = collection_scope.in(current_region).approved.include_for_box
    @locations = filter_collections(@locations)
    @locations = @locations.order("last_activity_at DESC").page(params[:page]).per(params[:per_page] || 15)
  
    @actual_newest_post_map = @locations.each_with_object({}) do |location, map|
      posts = location.location_posts.select { |p| p.created_at > 4.weeks.ago }
      menus = location.location_menus.select { |m| m.menu_to > Date.yesterday }
      newest = (posts + menus).max_by(&:created_at)
      map[location.id] = newest if newest
    end

  end

  def show
    @location = Location.includes(
      :images,
      comments: [:user, :images],
      zuckerls: [],
      crowd_campaigns: [],
      room_offers: [],
      room_demands: [],
      graetzl: []
    ).find(params[:id])

    # Nur redirect für Nicht-Admins!
    if @location.pending? && !(current_user&.admin?)
      redirect_enqueued and return
    end

    # Für Admins: Flash-Message anzeigen (ohne redirect)
    if @location.pending? && current_user&.admin?
      flash.now[:notice] = "Admin-Ansicht! Schaufenster noch nicht freigeschaltet."
    end

    return if redirect_to_region?(@location)

    @graetzl = @location.graetzl

    # IDs der zu ladenden Objekte über Union-Query holen
    query = <<~SQL
      (SELECT 'LocationPost' AS item_type, id, created_at FROM location_posts WHERE location_id = #{@location.id})
      UNION
      (SELECT 'LocationMenu' AS item_type, id, created_at FROM location_menus WHERE location_id = #{@location.id})
      UNION
      (SELECT 'Comment' AS item_type, id, created_at FROM comments WHERE commentable_id = #{@location.id} AND commentable_type = 'Location')
      ORDER BY created_at DESC
      LIMIT 60
    SQL

    results = ActiveRecord::Base.connection.select_all(query)

    post_ids  = results.select { |r| r['item_type'] == 'LocationPost' }.map { |r| r['id'] }
    menu_ids  = results.select { |r| r['item_type'] == 'LocationMenu' }.map { |r| r['id'] }
    comment_ids = results.select { |r| r['item_type'] == 'Comment' }.map { |r| r['id'] }

    posts = LocationPost.includes(:images).where(id: post_ids).index_by(&:id)
    menus = LocationMenu.includes(:images).where(id: menu_ids).index_by(&:id)
    comments = Comment.includes(:user, :images).where(id: comment_ids).index_by(&:id)

    comments.each_value do |comment|
      comment.define_singleton_method(:preloaded_user) { comment.user }
    end

    # Gemeinsame Methode zum Laden der assoziierten Kommentare
    preload_comments = ->(klass, ids) {
      Comment.includes(:user, :images)
            .where(commentable_type: klass, commentable_id: ids)
            .group_by(&:commentable_id)
    }

    post_comments = preload_comments.call('LocationPost', post_ids)
    menu_comments = preload_comments.call('LocationMenu', menu_ids)

    # Singleton-Methoden setzen (=> keine N+1 mehr)
    posts.each do |id, post|
      post.define_singleton_method(:preloaded_comments) { post_comments[id] || [] }
    end
    menus.each do |id, menu|
      menu.define_singleton_method(:preloaded_comments) { menu_comments[id] || [] }
    end

    # Stream zusammenbauen
    @stream = results.map do |result|
      case result['item_type']
      when 'LocationPost'
        posts[result['id']]
      when 'LocationMenu'
        menus[result['id']]
      when 'Comment'
        comments[result['id']]
      end
    end.compact

    @zuckerls = @location.zuckerls.live
    @crowd_campaign = @location.crowd_campaigns.funding.last
    @room_offer = @location.room_offers.enabled.last
    @room_demand = @location.room_demands.enabled.last
  end

  def new

    if params[:location_category_id].present?
      @location = current_user.locations.build(location_category_id: params[:location_category_id])
    else
      @location = current_user.locations.build(location_category_id: current_user.location_category_id)
    end

    @location.graetzl = user_home_graetzl

    if current_user.locations.approved.any? && !current_user.subscribed?
      flash.now[:notice] = "Du hast bereits ein Schaufenster. Um ein weiteres Schaufenster einzurichten, hole dir die #{view_context.link_to 'JUHU Fördermitgliedschaft', subscription_plans_path}."
    end
    
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

  def add_menu
    @location = fetch_user_location(params[:id])
    @location_menu = @location.location_menus.build(location_menu_params)
    if @location_menu.save
      ActionProcessor.track(@location, :menu, @location_menu)
    end
    render 'locations/location_menus/add'
  end

  def remove_post
    @location = fetch_user_location(params[:id])
    @location_post = @location.location_posts.find(params[:post_id])
    @location_post.destroy
    render 'locations/location_posts/remove'
  end

  def remove_menu
    @location = fetch_user_location(params[:id])
    @location_menu = @location.location_menus.find(params[:menu_id])
    @location_menu.destroy
    render 'locations/location_menus/remove'
  end

  def update_post
    @location = fetch_user_location(params[:id])
    @location_post = @location.location_posts.find(params[:post_id])
    if @location_post && @location_post.edit_permission?(current_user)
      @location_post.update(location_post_params)
      render 'locations/location_posts/update'
    else
      head :ok
    end
  end

  def update_menu
    @location = fetch_user_location(params[:id])
    @location_menu = @location.location_menus.find(params[:menu_id])
    if @location_menu && @location_menu.edit_permission?(current_user)
      @location_menu.update(location_menu_params)
      render 'locations/location_menus/update'
    else
      head :ok
    end
  end

  def comment_post
    @location = Location.find(params[:id])
    @location_post = @location.location_posts.find(params[:post_id])
    @comment = @location_post.comments.new(location_comment_params)
    @comment.user = current_user
    if @comment.save
      ActionProcessor.track(@location_post, :comment, @comment)
    end
    render 'locations/location_posts/comment'
  end

  def comment_menu
    @location = Location.find(params[:id])
    @location_menu = @location.location_menus.find(params[:menu_id])
    @comment = @location_menu.comments.new(location_comment_params)
    @comment.user = current_user
    if @comment.save
      ActionProcessor.track(@location_menu, :comment, @comment)
    end
    render 'locations/location_menus/comment'
  end

  def destroy
    @location = fetch_user_location(params[:id])
    @location.destroy
    redirect_to locations_user_path, notice: 'Dein Schaufenster wurde gelöscht'
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
      params[:favorites] = false
    elsif params[:special_category_id].present? && params[:special_category_id] == 'goodies'
      locations = locations.goodie
    elsif params[:special_category_id].present? && params[:special_category_id] == 'menus'
      locations = locations.menus
    elsif params[:category_id].present?
      locations = locations.where(location_category: params[:category_id])
    end

    if params[:favorites].present? && current_user
      locations = locations.where(graetzl_id: current_user.followed_graetzl_ids)
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      locations = locations.where(graetzl_id: graetzl_ids)
    end

    locations
  end

  def fetch_user_location(id)
    current_user.locations.find(id)
  end

  def redirect_enqueued
    message = 'Deine Schaufenster-Anfrage wird geprüft. Du erhältst eine Nachricht sobald sie bereit ist.'

    unless current_user&.admin?
      return redirect_to root_url, notice: message
    end

    redirect_to @location, notice: message
  end

  def location_params
    params.require(:location).permit(
      :name, :verified, :graetzl_id, :slogan, :description, :description_background, :description_favorite_place, :avatar, :remove_avatar, :cover_photo, :remove_cover_photo,
      :address_street, :address_coords, :address_city, :address_zip, :address_description,
      :location_category_id, :product_list, :website_url, :online_shop_url, :email, :phone, :open_hours, :goodie,
      images_attributes: [:id, :file, :_destroy],
    )
  end

  def location_post_params
    params.require(:location_post).permit(
      :title, :content, images_attributes: [:id, :file, :_destroy]
    )
  end

  def location_menu_params
    params.require(:location_menu).permit(
      :title, :description, :menu_from, :menu_to, images_attributes: [:id, :file, :_destroy]
    )
  end

  def location_comment_params
    params.require(:comment).permit(
      :content,
      images_attributes: [:file],
    )
  end

end
