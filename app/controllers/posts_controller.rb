class PostsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_graetzl

  def create
    @post = @graetzl.posts.build(post_params)
    if @post.save
      @post.create_activity :create, owner: current_user
    else
      render nothing: true
    end
  end

  private

    def set_graetzl
      @graetzl = Graetzl.find(params[:graetzl_id])
    end

    def post_params
      params.require(:post).permit(:content).merge(user_id: current_user.id)
    end
end
