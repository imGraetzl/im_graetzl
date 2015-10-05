class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_graetzl, only: [:show]

  def show
    @user = User.includes(:comments, meetings: [:going_tos]).find(params[:id])
    redirect_to([@user.graetzl, @user], status: 301) if wrong_graetzl?
  end

  def edit
    @user = current_user
  end

  def locations
    @locations = current_user.locations.includes(:location_ownerships)
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
end
