class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_graetzl, only: [:show]

  def show
    @user = User.includes(wall_comments: [:images]).find(params[:id])
    if request.xhr?
      @new_content = paginate_show(@scope = params[:scope].to_sym)
    else
      @initiated = @user.meetings.initiated.page(params[:initiated]).per(3)
      @attended = @user.meetings.attended.page(params[:attended]).per(3)
      @wall_comments = @user.wall_comments.page(params[:page]).per(10)
      redirect_to([@user.graetzl, @user], status: 301) if wrong_graetzl?
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

  def set_graetzl
    @graetzl = Graetzl.find_by_slug(params[:graetzl_id])
  end

  def wrong_graetzl?
    !@graetzl || (@graetzl != @user.graetzl)
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

  def paginate_show(scope)
    case scope
    when :wall_comments
      @user.wall_comments.page(params[:page]).per(10)
    when :initiated
      @user.meetings.basic.initiated.page(params[scope]).per(3)
    when :attended
      @user.meetings.basic.attended.page(params[scope]).per(3)
    end
  end
end
