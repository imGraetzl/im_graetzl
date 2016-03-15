class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    if request.xhr?
      @user = User.find(params[:id])
      paginate_content
    else
      set_user_and_graetzl
      @wall_comments = @user.wall_comments.order(created_at: :desc).page(params[:page]).per(10)
      @initiated = @user.meetings.initiated.page(params[:initiated]).per(3)
      @attended = @user.meetings.attended.page(params[:attended]).per(3)
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      sign_in @user, bypass: true
      redirect_to [@user.graetzl, @user], notice: 'Profil gespeichert!'
    else
      render :edit
    end
  end

  private

  def set_user_and_graetzl
    @user = User.includes(wall_comments: [:images]).find(params[:id])
    @graetzl = Graetzl.find_by_slug(params[:graetzl_id])
    redirect_to([@user.graetzl, @user], status: 301) if wrong_graetzl?
  end

  def wrong_graetzl?
    !@graetzl || (@graetzl != @user.graetzl)
  end

  def paginate_content
    case
    when params[:page]
      @wall_comments = @user.wall_comments.order(created_at: :desc).page(params[:page]).per(10)
    when params[:initiated]
      @initiated = @user.meetings.initiated.page(params[:initiated]).per(3)
    when params[:attended]
      @attended = @user.meetings.attended.page(params[:attended]).per(3)
    end
  end

  def user_params
    params[:user].delete(:password) if params[:user][:password].blank?
    params.
      require(:user).
      permit(:email,
        :password,
        :first_name,
        :last_name,
        :website,
        :bio,
        :newsletter,
        :role,
        :avatar, :remove_avatar,
        :cover_photo, :remove_cover_photo)
  end
end
