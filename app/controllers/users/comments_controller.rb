class Users::CommentsController < CommentsController
  before_action :set_commentable

  # override create for wall_posts
  def create
    @comment = @commentable.wall_posts.build(comment_params)
    super
  end

  private

    def set_commentable
      @commentable = User.find(params[:user_id])
    end

    def log_activity?
      @commentable != current_user
    end
end