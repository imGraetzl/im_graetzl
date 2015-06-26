class CommentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_commentable
  before_filter :set_form_id, only: [:create]

  def create
    @comment = @commentable.comments.build(comment_params)
    if @comment.save
      @commentable.create_activity :comment, owner: current_user, recipient: @comment
      respond_to do |format|
        format.js
        format.html { redirect_to [@commentable.graetzl, @commentable] }
      end
    else
      render nothing: true
    end
  end

  private

    def find_commentable
      klass = params[:commentable_type].constantize
      @commentable = klass.find(params[:commentable_id])  
    end

    def set_form_id
      @form_id = params[:form_id]
    end

    def comment_params
      params.require(:comment).permit(:content, images_files: []).merge(user_id: current_user.id)
    end
end