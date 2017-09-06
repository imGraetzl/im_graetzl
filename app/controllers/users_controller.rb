class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    if !request.xhr?
      @graetzl = Graetzl.find_by_slug(params[:graetzl_id])
      redirect_to([@user.graetzl, @user], status: 301) and return if wrong_graetzl?(@user, @graetzl)
      @wall_comments = load_comments(params[:page])
      @initiated = load_initiated_meetings(params[:initiated])
      @attended = load_attended_meetings(params[:attended])
    else
      @wall_comments = load_comments(params[:page]) if params[:page]
      @initiated = load_initiated_meetings(params[:initiated]) if params[:initiated]
      @attended = load_attended_meetings(params[:attended]) if params[:attended]
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      bypass_sign_in @user
      redirect_to [@user.graetzl, @user], notice: 'Profil gespeichert!'
    else
      render :edit
    end
  end

  private

  def wrong_graetzl?(user, graetzl)
    graetzl.nil? || user.graetzl != graetzl
  end

  def load_comments(page)
    @user.wall_comments.includes(:user, :images).order(created_at: :desc).page(page).per(10)
  end

  def load_initiated_meetings(page)
    @user.meetings.initiated.include_for_box.page(page).per(3)
  end

  def load_attended_meetings(page)
    @user.meetings.attended.include_for_box.page(page).per(3)
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
