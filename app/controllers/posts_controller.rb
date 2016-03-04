class PostsController < ApplicationController
  # before_action :authenticate_user!
  #
  # def create
  #   @post = @author.posts.new post_params
  #   if @post.save
  #     @activity = @post.create_activity :create, owner: current_user
  #   end
  # end
  #
  # def show
  #   @post = Post.includes(:images, :author, comments: [:user, :images]).find(params[:id])
  #   redirect_to :back, notice: 'Diese Seite existiert leider nicht.' if @post.author.is_a?(Location)
  #   @comments = @post.comments.page(params[:page]).per(10)
  # end
  #
  # def destroy
  #   @post = Post.find(params[:id])
  #   @element_id = "post_#{@post.id}"
  #   graetzl = @post.graetzl
  #   if @post.destroy
  #     respond_to do |format|
  #       format.html { redirect_to graetzl, notice: 'Beitrag gelöscht' }
  #       format.js
  #     end
  #   else
  #     respond_to do |format|
  #       format.html { redirect_to :back, notice: 'Konnte Beitrag nicht löschen' }
  #       format.js
  #     end
  #   end
  # end
  #
  # private
  #
  # def post_params
  #   params.require(:post).permit(:graetzl_id,
  #                                 :title,
  #                                 :content,
  #                                 images_files: [])
  # end
end
