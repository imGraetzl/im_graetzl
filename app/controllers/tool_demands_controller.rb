class ToolDemandsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @tool_demands = collection_scope.in(current_region).includes(:user)
    @tool_demands = filter_collection(@tool_demands)
    @tool_demands = @tool_demands.by_currentness.page(params[:page]).per(params[:per_page] || 15)
  end

  def show
    @tool_demand = ToolDemand.find(params[:id])
    return if redirect_to_region?(@tool_demand)
    @comments = @tool_demand.comments.includes(:user, :images).order(created_at: :desc)
  end

  def new
    @tool_demand = ToolDemand.new(current_user.slice(:first_name, :last_name, :email, :website))
  end

  def create
    @tool_demand = ToolDemand.new(tool_demand_params)
    @tool_demand.user_id = current_user.id
    @tool_demand.region_id = current_region.id

    if @tool_demand.save
      ToolMailer.tool_demand_published(@tool_demand).deliver_later
      ActionProcessor.track(@tool_demand, :create)
      redirect_to @tool_demand
    else
      render 'new'
    end
  end

  def edit
    @tool_demand = current_user.tool_demands.find(params[:id])
  end

  def update
    @tool_demand = current_user.tool_demands.find(params[:id])
    @tool_demand.assign_attributes(tool_demand_params)

    if @tool_demand.save
      redirect_to @tool_demand
    else
      render 'edit'
    end
  end

  def update_status
    @tool_demand = current_user.tool_demands.find(params[:id])
    @tool_demand.update(status: params[:status])
    flash[:notice] = t("activerecord.attributes.tool_demand.status_message.#{@tool_demand.status}")
    redirect_back(fallback_location: tools_user_path)
  end

  def destroy
    @tool_demand = current_user.tool_demands.find(params[:id])
    @tool_demand.destroy
    redirect_to tools_user_path
  end

  private

  def collection_scope
    if params[:user_id].present?
      ToolDemand.enabled.where(user_id: params[:user_id])
    else
      ToolDemand.enabled
    end
  end

  def filter_collection(collection)

    if params[:category_id].present?
      collection = collection.where(tool_category_id: params[:category_id])
    end

    graetzl_ids = params.dig(:filter, :graetzl_ids)
    if params[:favorites].present? && current_user
      collection = collection.where(graetzl_id: current_user.followed_graetzl_ids)
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      collection = collection.where(graetzl_id: graetzl_ids)
    end

    collection
  end

  def tool_demand_params
    params
      .require(:tool_demand)
      .permit(
        :slogan,
        :demand_description,
        :usage_description,
        :budget,
        :first_name, :last_name, :website, :email, :phone, :location_id,
        :usage_period, :usage_period_from, :usage_period_to, :usage_days,
        :tool_category_id,
        images_attributes: [:id, :file, :_destroy],
        graetzl_ids: [],
    ).merge(
      keyword_list: params[:custom_keywords]
    )
  end

end
