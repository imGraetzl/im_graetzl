class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def toggle_favorite

    favoritable_id = params[:id]
    favoritable_type = params[:format]

    favoritable = current_user.favorites.where(favoritable_id: favoritable_id, favoritable_type: favoritable_type).last
    @favorite_element = "#{favoritable_type.underscore}-#{favoritable_id}"
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
    favorites = current_user.favorites.includes(:favoritable).order(created_at: :desc).map(&:favoritable)

    if params.dig(:filter, :type).present?
      type_classes = params.dig(:filter, :type)
      favorites = favorites.select { |f| type_classes.include?(f.class.name.underscore) }
    end

    @favorites = Kaminari.paginate_array(favorites).page(params[:page]).per(params[:per_page] || 21)
  end

end
