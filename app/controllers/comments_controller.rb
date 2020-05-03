class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comment = current_user.comments.new(comment_params)
    if @comment.save

      if @comment.commentable_type == 'Meeting' && @comment.commentable.online_meeting
        @comment.commentable.create_activity :comment, owner: current_user, recipient: @comment, parameters: { cross_platform: true }
      else
        @comment.commentable.create_activity :comment, owner: current_user, recipient: @comment
      end

    end
  end

  def destroy
    @comment = Comment.find(params[:id]).destroy
  end

  private

  def comment_params
    params.require(:comment).permit(
      :commentable_id,
      :commentable_type,
      :content,
      images_files: []
    )
  end
end
