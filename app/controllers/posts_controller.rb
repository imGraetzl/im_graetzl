class PostsController < ApplicationController
  before_action :authenticate_user!

  def create
    @post = @author.posts.new post_params
    puts 'HERE HERE HERE HERE HERE HERE HERE HERE'
    puts @post.attributes
    puts @post.valid?
    puts @post.errors
    if @post.save
      puts 'POST SAVED POST SAVED POST SAVED POST SAVED'
    end
    # @post = Post.new(post_params)
    # if @post.save
    #   @activity = @post.create_activity :create, owner: current_user
    # end
    # if post.save
    #   @activity = post.create_activity :create, owner: current_user
    #   render partial: 'public_activity/post/create', layout: 'stream/element', locals: { activity: @activity } and return
    # else
    #   render nothing: true, status: :internal_server_error
    # end
  end

  def show
    @post = Post.includes(:images, :user, comments: [:user, :images]).find(params[:id])
    @comments = @post.comments.page(params[:page]).per(10)
  end

  def destroy
    @post = Post.find(params[:id])
    @element_id = "post_#{@post.id}"
    graetzl = @post.graetzl
    if @post.destroy
      respond_to do |format|
        format.html { redirect_to graetzl, notice: 'Beitrag gelöscht' }
        format.js
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, notice: 'Konnte Beitrag nicht löschen' }
        format.js
      end
    end
    # @post = Post.find(params[:id])
    # graetzl = @post.graetzl
    # if @post.destroy
    #   respond_to do |format|
    #     format.html { redirect_to graetzl, notice: 'Beitrag gelöscht' }
    #     format.js { render nothing: true, status: :ok }
    #   end
    # else
    #   respond_to do |format|
    #     format.html { redirect_to :back, notice: 'Konnte Beitrag nicht löschen' }
    #     format.js { render nothing: true, status: :internal_server_error }
    #   end
    # end
  end

  private

  def post_params
    params.
      require(:post).
      permit(:graetzl_id,
              :title,
              :content,
              images_files: [])
  end

  # def post_params
  #   params.
  #     require(:post).
  #     permit(:graetzl_id, :content, images_files: []).
  #     merge(user_id: current_user.id)
  # end
end
