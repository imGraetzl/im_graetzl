class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_graetzl, only: [:show]

  def show
    @user = User.includes(:comments, meetings: [:going_tos]).find(params[:id])
    redirect_to([@user.graetzl, @user], status: 301) if wrong_graetzl?
  end

  private  

  def set_graetzl
    @graetzl = Graetzl.find_by_slug(params[:graetzl_id])
  end

  def wrong_graetzl?
    !@graetzl || (@graetzl != @user.graetzl)
  end
end
