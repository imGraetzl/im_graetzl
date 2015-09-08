class PostsController < ApplicationController
  before_action :authenticate_user!

  def create
    post = Post.new(post_params)
    if post.save
      @activity = post.create_activity :create, owner: current_user
      render partial: 'public_activity/post/create', layout: 'stream/element', locals: { activity: @activity } and return
    else
      render nothing: true, status: :internal_server_error
    end
  end

  def show
    @post = Post.includes(:images, :user, comments: [:user, :images]).find(params[:id])
  end

  private

    def post_params
      params.
        require(:post).
        permit(:graetzl_id, :content, images_files: []).
        merge(user_id: current_user.id)
    end
end
