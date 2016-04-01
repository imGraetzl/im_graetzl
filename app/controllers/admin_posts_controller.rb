class AdminPostsController < ApplicationController
  def show
    @post = AdminPost.find params[:id]
    @comments = @post.comments.order(created_at: :desc).page(params[:page]).per(10)
  end
end
