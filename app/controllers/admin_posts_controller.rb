class AdminPostsController < ApplicationController
  def show
    @post = AdminPost.find(params[:id])
    @comments = @post.comments.includes(:user, :images).order(created_at: :desc)
  end

  def destroy
    @post = AdminPost.find(params[:id]).destroy
    redirect_to root_url, notice: 'Beitrag gelöscht'
  end

end
