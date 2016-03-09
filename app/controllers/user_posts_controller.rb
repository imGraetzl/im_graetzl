class UserPostsController < ApplicationController
  before_action :authenticate_user!

  def new
    set_graetzl
    @user_post = current_user.posts.build graetzl: @graetzl
  end

  def create
    set_graetzl
    @user_post = current_user.posts.new user_post_params
    if @user_post.save
      # @user_post.create_activity :create, owner: current_user
      redirect_to graetzl_post_path(@graetzl, @user_post)
    else
      render :new
    end
  end

  private

  def set_graetzl
    @graetzl = Graetzl.find(params[:graetzl_id])
  end

  def user_post_params
    params.require(:user_post).permit(
      :graetzl_id,
      :title,
      :content,
      images_files: [])
  end
end
