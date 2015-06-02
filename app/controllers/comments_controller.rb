class CommentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_commentable

  def create
    comment = @commentable.comments.build(comment_params)
    if comment.save
      #@activity = post.create_activity :create, owner: current_user
    else
      render nothing: true
    end
  end

  private

    def find_commentable
      klass = params[:commentable_type].constantize
      @commentable = klass.find(params[:commentable_id])      
    end

    def comment_params
      params.require(:comment).permit(:content).merge(user_id: current_user.id)
    end
end