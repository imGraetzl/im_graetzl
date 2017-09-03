class Api::ApiController < ApplicationController
  before_action :check_api_key

  private

  def check_api_key
    api_key = params[:api_key] || request.headers['ImGraetzl-Api-Key']
    head :unauthorized unless api_key.present? && ApiAccount.exists?(api_key: api_key)
  end

end
