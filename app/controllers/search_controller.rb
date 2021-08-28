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

  def address
    render json: AddressSearch.new.search(current_region, params[:q])
  end

  def graetzls
    render json: District.memoized(params[:district_id]).graetzls.to_json(only: [:id, :name])
  end

  def search_params
    params.permit(:page, :per_page).merge(type: params.dig(:filter, :search_type))
  end

end
