class PostsController < ApplicationController
  include GraetzlChild
  before_action :authenticate_user!, only: [:destroy]

  def index
    @posts = @graetzl.posts.where(type: UserPost)
      .includes(:graetzl, author: [:graetzl])
      .order(created_at: :desc).
      page(params[:page]).per(15)
  end

  def destroy
    @post = Post.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to @post.graetzl, notice: 'Beitrag gelöscht' }
      format.js
    end
  end
end
