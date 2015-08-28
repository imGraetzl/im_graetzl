class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_form_id, only: [:create]

  def create
    @comment = @commentable.comments.build(comment_params)
    if @comment.save
      @commentable.create_activity :comment, owner: current_user, recipient: @comment
    else
      render nothing: true
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
    if @comment.destroy
      render nothing: true, status: :ok
    else
      render nothing: true, status: :internal_server_error
    end
  end

  private

    def set_form_id
      @form_id = params[:form_id]
    end

    def comment_params
      params.require(:comment).permit(:content, images_files: []).merge(user_id: current_user.id)
    end
end