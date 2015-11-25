class Users::PostsController < PostsController
  before_action :set_author

  private

  def set_author
    @author = User.find(params[:user_id])
  end
end
