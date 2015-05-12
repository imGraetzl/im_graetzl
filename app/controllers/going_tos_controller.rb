class GoingTosController < ApplicationController
  before_filter :authenticate_user!

  def create
    meeting = Meeting.find(params[:meeting_id])
    current_user.go_to(meeting)
  end

  def destroy
    GoingTo.find(params[:id]).destroy
  end
end