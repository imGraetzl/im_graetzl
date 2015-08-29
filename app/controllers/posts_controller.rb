class PostsController < ApplicationController
  before_action :authenticate_user!

  def create
    post = Post.new(post_params)
    # tmp set graetzl:    
    @graetzl = post.graetzl
    if post.save
      @activity = post.create_activity :create, owner: current_user
    else
      render nothing: true
    end
  end

  private

    def post_params
      params.
        require(:post).
        permit(:graetzl_id, :content, images_files: []).
        merge(user_id: current_user.id)
    end
end
