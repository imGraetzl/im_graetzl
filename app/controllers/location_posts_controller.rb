class LocationPostsController < ApplicationController
  # TODO authenticate user belongs to location...
  before_action :authenticate_user!

  def create
    @location_post = LocationPost.new location_post_params
    if @location_post.save
      @location_post.create_activity :create, owner: current_user
    end
  end

  private

  def location_post_params
    params.require(:location_post).permit(
      :graetzl_id,
      :author_id,
      :author_type,
      :title,
      :content,
      images_files: [])
  end
end
