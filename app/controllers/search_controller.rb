class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def user
    @results = SearchService.new(current_region, params[:q]).user
    respond_to { |format| format.json }
  end

  def autocomplete
    @results = SearchService.new(current_region, params[:q]).sample
    respond_to { |format| format.json }
  end

  def results
    head :ok and return if browser.bot? && !request.format.js?
    @results = SearchService.new(current_region, params[:q], search_params).search
  end

  def search_params
    params.permit(:page, :per_page).merge(type: params.dig(:filter, :search_type))
  end

end
