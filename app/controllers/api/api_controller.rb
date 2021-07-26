class Api::ApiController < ApplicationController
  before_action :check_api_key

  private

  def check_api_key
    if api_key.blank? || current_api_account.blank?
      head :unauthorized
    end
  end

  def current_api_account
    @api_account = ApiAccount.in(current_region).enabled.find_by(api_key: api_key)
  end

  def api_key
    params[:api_key] || request.headers['ImGraetzl-Api-Key']
  end

end
