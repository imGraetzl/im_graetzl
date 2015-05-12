class GoingTosController < ApplicationController
  before_filter :authenticate_user!

  def create
    @meeting = Meeting.find(params[:meeting_id])
    current_user.go_to(@meeting)
  end

  def destroy
    going_to = GoingTo.find(params[:id])
    @meeting = going_to.meeting
    going_to.destroy
  end
end