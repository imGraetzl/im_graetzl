class TriageController < ApplicationController

  # Redirect the static URL of an asset to its current fingerprinted equivalent.
  def static_asset
    response.headers['Access-Control-Allow-Origin'] = '*'
    redirect_to ActionController::Base.helpers.asset_url(params[:path])
  end

end
