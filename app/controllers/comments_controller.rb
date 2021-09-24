class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comment = current_user.comments.new(comment_params)
    if @comment.save
      ActionProcessor.track(@comment.commentable, :comment, @comment)
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
      images_attributes: [:file]
    )
  end
end
