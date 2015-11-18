class Locations::PostsController < PostsController
  before_action :set_author

  private

  def set_author
    @author = Location.find(params[:location_id])
  end
end
