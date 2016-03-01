class Users::CommentsController < CommentsController
  before_action :set_commentable

  # override create for wall_comments
  def create
    @comment = @commentable.wall_comments.new comment_params
    if @comment.save
      @commentable.create_activity :comment, owner: current_user, graetzl_id: @commentable.graetzl_id, recipient: @comment if log_activity?
    end
  end

  private

  def set_commentable
    @commentable = User.find(params[:user_id])
  end

  def log_activity?
    @commentable != current_user
  end
end
