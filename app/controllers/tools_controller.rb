class ToolsController < ApplicationController

  def index
    head :ok and return if browser.bot? && !request.format.js?

    tool_offers = tool_offers_scope.in(current_region).includes(:user)
    tool_offers = filter_offers(tool_offers)
    tool_offers = tool_offers.by_currentness.page(params[:page]).per(params[:per_page] || 10)

    tool_demands = tool_demands_scope.in(current_region).includes(:user)
    tool_demands = filter_demands(tool_demands)
    tool_demands = tool_demands.by_currentness.page(params[:page]).per(params[:per_page] || 10)

    @tools = []
    @tools += (tool_offers + tool_demands).sort_by(&:created_at).reverse
    @next_page = tool_offers.next_page.present? || tool_demands.next_page.present?
  end

  private

  def tool_offers_scope
    if params[:district_id].present?
      ToolOffer.where(district_id: params[:district_id])
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
      user.tool_offers.enabled
    else
      ToolOffer.enabled
    end
  end

  def tool_demands_scope
    if params[:district_id].present?
      district = District.find(params[:district_id])
      ToolDemand.joins(:tool_demand_graetzls).where(tool_demand_graetzls: {graetzl_id: district.graetzl_ids}).distinct
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
      user.tool_demands.enabled
    else
      ToolDemand.enabled
    end
  end

  def filter_offers(collection)

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

  def filter_demands(collection)
    graetzl_ids = params.dig(:filter, :graetzl_ids)

    if params[:category_id].present?
      collection = collection.where(tool_category_id: params[:category_id])
    end

    if params[:favorites].present? && current_user
      favorite_ids = current_user.followed_graetzl_ids
      collection = collection.joins(:tool_demand_graetzls).where(tool_demand_graetzls: {graetzl_id: favorite_ids}).distinct
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      collection = collection.joins(:tool_demand_graetzls).where(tool_demand_graetzls: {graetzl_id: graetzl_ids}).distinct
    end

    collection
  end

end
