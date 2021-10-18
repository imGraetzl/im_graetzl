class DiscussionPostsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :comments]
  before_action :check_group

  def create
    @discussion = @group.discussions.find(params[:discussion_id])
    redirect_to [@group, @discussion] and return if @discussion.nil? || @discussion.closed?

    @post = @discussion.discussion_posts.new(discussion_post_params)
    @post.user = current_user
    if @post.save
      @discussion.discussion_followings.find_or_create_by(user: current_user)
      ActionProcessor.track(@discussion, :post) # new activitiy for each post (test it in stream..)
      ActionProcessor.track(@post, :create)
      redirect_to [@group, @discussion, anchor: "discussion-post-#{@post.id}" ]
    else
      redirect_to [@group, @discussion]
    end
  end

  def comment
    @post = @group.discussion_posts.find(params[:discussion_post_id])
    @comment = @post.comments.new comment_params
    if @comment.save
      ActionProcessor.track(@post, :comment, @comment)
    end
    respond_to do |format|
      format.js { render "groups/discussion_posts/comment" }
    end
  end

  def update
    @post = @group.discussion_posts.find(params[:id])
    if @post && @post.edit_permission?(current_user)
      @post.update(discussion_post_params)
      render 'groups/discussion_posts/update'
    else
      head :ok
    end
  end

  def destroy
    @post = @group.discussion_posts.find(params[:id])
    if @post && @post.delete_permission?(current_user)
      @post.destroy
      render 'groups/discussion_posts/destroy'
    else
      head :ok
    end
  end

  private

  def check_group
    @group = Group.find(params[:group_id])
    if @group.nil?
      redirect_to root_url
    elsif !@group.readable_by?(current_user)
      redirect_to [@group, @discussion]
    end
  end

  def discussion_post_params
    params.require(:discussion_post).permit(
      :content,
      images_attributes: [:id, :file, :_destroy],
    )
  end

  def comment_params
    params.require(:comment).permit(
      :content,
      images_attributes: [:file]
    ).merge(user_id: current_user.id)
  end

end
