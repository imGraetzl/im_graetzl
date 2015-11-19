class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comment ||= @commentable.comments.build(comment_params)
    if @comment.save
      #@commentable.create_activity :comment, owner: current_user, recipient: @comment if log_activity?
      #render partial: 'comment', locals: { comment: @comment, comment_inline: true } and return if inline?
      #render partial: 'comment', layout: 'layouts/stream/element', locals: { comment: @comment } and return
    else
      #render nothing: true, status: :internal_server_error
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
      params[:inline] == 'true'
    end

    def comment_params
      params.require(:comment).permit(:content, images_files: []).merge(user_id: current_user.id)
    end

    def log_activity?
      @commentable != current_user
    end
end
