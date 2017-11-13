class AdminPostsController < ApplicationController
  def show
    @post = AdminPost.find(params[:id])
    @comments = @post.comments.includes(:user, :images).order(created_at: :desc)
  end
end
