class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def toggle_favorite

    favoritable_id = params[:id]
    favoritable_type = params[:format]

    favoritable = current_user.favorites.where(favoritable_id: favoritable_id, favoritable_type: favoritable_type).last

    if favoritable
      @favoritable = favoritable.destroy
      @favor = false
    else
      @favoritable = current_user.favorites.create(favoritable_id: favoritable_id, favoritable_type: favoritable_type)
      @favor = true
    end

  end

  # TODO: implement favorite_type filter
  def results
    head :ok and return if browser.bot? && !request.format.js?
    favorites = current_user.favorites.includes(:favoritable).order(:created_at).map(&:favoritable)
    @favorites = Kaminari.paginate_array(favorites).page(params[:page]).per(params[:per_page] || 15)
  end

end
