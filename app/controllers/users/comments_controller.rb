class Users::CommentsController < CommentsController
  before_action :set_commentable

  # override create for wall_comments
  def create
    @comment = @commentable.wall_comments.build(comment_params)
    super
  end

  private

    def set_commentable
      @commentable = User.find(params[:user_id])
    end
end