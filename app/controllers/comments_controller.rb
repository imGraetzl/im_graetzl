class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :inline?, only: [:create]

  def create
    @comment = @commentable.comments.new comment_params
    if @comment.save
      @commentable.create_activity :comment, owner: current_user, recipient: @comment
    end
  end

  def update
    @comment = Comment.find(params[:id])
    if @comment.update(content: params[:content])
      render text: @comment.content
    else
      render text: 'Es gab ein Problem...'
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @element_id = "comment_#{@comment.id}"
    @comment.destroy
  end

  private

  def inline?
    @inline = params[:inline] == 'true'
  end

  def comment_params
    params.require(:comment).permit(:content, images_files: []).merge(user_id: current_user.id)
  end
end
