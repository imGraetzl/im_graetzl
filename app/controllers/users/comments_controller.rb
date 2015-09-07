class Users::CommentsController < CommentsController
  before_action :set_commentable

  # override create for wall_posts
  def create
    @comment = @commentable.wall_posts.build(comment_params)
    # if comment.save
    #   @commentable.create_activity :comment, owner: current_user, recipient: comment if log_activity?
    #   render partial: 'comment', locals: { comment: comment, comment_inline: true } and return if inline?
    #   render partial: 'comment', layout: 'layouts/stream/element', locals: { comment: comment } and return      
    # else
    #   render nothing: true, status: :internal_server_error
    # end
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