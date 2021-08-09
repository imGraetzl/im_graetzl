class CoopDemandsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :activate]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @coop_demands = collection_scope.in(current_region).includes(:user)
    @coop_demands = filter_collection(@coop_demands)
    @coop_demands = @coop_demands.by_currentness.page(params[:page]).per(params[:per_page] || 15)
  end

  def show
    @coop_demand = CoopDemand.in(current_region).find(params[:id])
    @comments = @coop_demand.comments.includes(:user, :images).order(created_at: :desc)
  end

  def new
    @coop_demand = CoopDemand.new
    @coop_demand.assign_attributes(current_user.slice(:first_name, :last_name, :email, :website))
  end

  def create
    @coop_demand = CoopDemand.new(coop_demand_params)
    @coop_demand.user_id = current_user.admin? ? params[:user_id] : current_user.id
    @coop_demand.region_id = current_region.id

    if @coop_demand.save
      #MailchimpCoopDemandUpdateJob.perform_later(@coop_demand)
      #RoomMailer.coop_demand_published(@coop_demand).deliver_later
      @coop_demand.create_activity(:create, owner: @coop_demand.user)
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

    ########
    # Set new last_activated_at date if edit and last_activated_at is more then 7 days ago
    if params[:last_activated_at] <= 7.days.ago && @coop_demand.enabled?
      @coop_demand.last_activated_at = Time.now
    end
    #########

    if @coop_demand.update(coop_demand_params)
      #MailchimpCoopDemandUpdateJob.perform_later(@coop_demand)
      redirect_to @coop_demand
    else
      render 'edit'
    end
  end

  def update_status
    @coop_demand = current_user.coop_demands.find(params[:id])
    @coop_demand.update(status: params[:status])
    @coop_demand.update(last_activated_at: @coop_demand.set_last_activated_at) if @coop_demand.enabled?
    #MailchimpCoopDemandUpdateJob.perform_later(@coop_demand)
    flash[:notice] = t("activerecord.attributes.coop_demand.status_message.#{@coop_demand.status}")
    redirect_back(fallback_location: coop_demands_user_path)
  end

  def activate
    @coop_demand = CoopDemand.find(params[:id])
    if params[:activation_code].to_i == @coop_demand.activation_code
      @coop_demand.update(:last_activated_at => @coop_demand.set_last_activated_at, :status => "enabled")
      flash[:notice] = "Dein Raumteiler wurde erfolgreich verlängert!"
    else
      flash[:notice] = "Der Aktivierungslink ist leider ungültig. Log dich ein um deinen Raumteiler zu aktivieren."
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
    category_ids = params.dig(:filter, :category_ids)

    if category_ids.present? && category_ids.any?(&:present?)
      collection = collection.joins(:coop_demand_category).where(coop_demand_category: {id: category_ids}).distinct
    end

    if graetzl_ids.present? && graetzl_ids.any?(&:present?)
      collection = collection.joins(:coop_demand_graetzls).where(coop_demand_graetzls: {graetzl_id: graetzl_ids}).distinct
    end

    collection
  end

  def coop_demand_params
    params
      .require(:coop_demand)
      .permit(
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
