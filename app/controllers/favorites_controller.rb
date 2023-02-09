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

  def results
    head :ok and return if browser.bot? && !request.format.js?
    @favorites = FavoriteService.new(current_user, favorite_params).favorites
  end

  private

  def favorite_params
    params.permit(:page, :per_page).merge(type: params.dig(:filter, :favorite_type))
  end

end
