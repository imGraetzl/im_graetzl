class GoingTosController < ApplicationController
  before_filter :authenticate_user!

  def create
    meeting = Meeting.find(params[:meeting_id])
    current_user.go_to(meeting)
  end

  def destroy
    meeting = Meeting.find(params[:meeting_id])
    current_user.going_tos.find_by_meeting_id(44).destroy    
  end
end