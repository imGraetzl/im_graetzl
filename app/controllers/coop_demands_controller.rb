class CoopDemandsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :reactivate]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @coop_demands = collection_scope.in(current_region).includes(:user)
    @coop_demands = filter_collection(@coop_demands)
    @coop_demands = @coop_demands.by_currentness.page(params[:page]).per(params[:per_page] || 15)
  end

  def show
    @coop_demand = CoopDemand.find(params[:id])
    redirect_to_region?(@coop_demand)
    @comments = @coop_demand.comments.includes(:user, :images).order(created_at: :desc)
  end

  def new
    @coop_demand = CoopDemand.new
    @coop_demand.assign_attributes(current_user.slice(:first_name, :last_name, :email, :website))
    @coop_demand.graetzls = [user_home_graetzl] + current_user.favorite_graetzls if !current_region.use_districts? && user_home_graetzl
  end

  def create
    @coop_demand = CoopDemand.new(coop_demand_params)
    @coop_demand.user_id = current_user.admin? ? params[:user_id] : current_user.id
    @coop_demand.region_id = current_region.id
    @coop_demand.activate

    if @coop_demand.save
      CoopDemandMailer.coop_demand_published(@coop_demand).deliver_later
      ActionProcessor.track(@coop_demand, :create)
      redirect_to @coop_demand
    else
      render 'new'
    end
  end

  def edit
    @coop_demand = current_user.coop_demands.find(params[:id])
  end

  def update
    @coop_demand = current_user.coop_demands.find(params[:id])

    if @coop_demand.update(coop_demand_params)
      ActionProcessor.track(@coop_demand, :update) if @coop_demand.refresh_activity
      redirect_to @coop_demand
    else
      render 'edit'
    end
  end

  def update_status
    @coop_demand = current_user.coop_demands.find(params[:id])
    @coop_demand.update(status: params[:status])
    ActionProcessor.track(@coop_demand, :update) if @coop_demand.refresh_activity
    flash[:notice] = t("activerecord.attributes.coop_demand.status_message.#{@coop_demand.status}")
    redirect_back(fallback_location: coop_demands_user_path)
  end

  def reactivate
    @coop_demand = CoopDemand.find(params[:id])
    if @coop_demand.disabled? && params[:activation_code].to_i == @coop_demand.activation_code
      @coop_demand.update(status: :enabled)
      ActionProcessor.track(@coop_demand, :update) if @coop_demand.refresh_activity
      flash[:notice] = "Dein Coop & Share Angebot wurde erfolgreich verlängert!"
    elsif @coop_demand.enabled?
      flash[:notice] = "Dein Coop & Share Angebot ist bereits aktiv."
    else
      flash[:notice] = "Der Aktivierungslink ist leider ungültig. Log dich ein um dein Coop & Share Angebot zu aktivieren."
    end
    redirect_to @coop_demand
  end

  def destroy
    @coop_demand = current_user.coop_demands.find(params[:id])
    @coop_demand.destroy

    redirect_to coop_demands_user_path
  end

  private

  def collection_scope
    if params[:user_id].present?
      CoopDemand.enabled.where(user_id: params[:user_id])
    else
      CoopDemand.enabled
    end
  end

  def filter_collection(collection)
    graetzl_ids = params.dig(:filter, :graetzl_ids)

    if params[:category_id].present?
      collection = collection.where(coop_demand_category: params[:category_id])
    end

    if params[:favorites].present? && current_user
      favorite_ids = current_user.followed_graetzl_ids
      collection = collection.joins(:coop_demand_graetzls).where(coop_demand_graetzls: {graetzl_id: favorite_ids}).distinct
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      collection = collection.joins(:coop_demand_graetzls).where(coop_demand_graetzls: {graetzl_id: graetzl_ids}).distinct
    end

    collection
  end

  def coop_demand_params
    params
      .require(:coop_demand)
      .permit(
        :coop_type,
        :slogan,
        :demand_description,
        :personal_description,
        :tenant_description,
        :avatar,
        :activation_code,
        :remove_avatar,
        :last_activated_at,
        :first_name, :last_name, :website, :email, :phone, :location_id,
        :coop_demand_category_id,
        images_attributes: [:id, :file, :_destroy],
        graetzl_ids: [],
    ).merge(
      keyword_list: [params[:suggested_keywords], params[:custom_keywords]].join(", ")
    )
  end
end
