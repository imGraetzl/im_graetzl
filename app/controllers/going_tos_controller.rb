class GoingTosController < ApplicationController
  before_action :authenticate_user!

  def create
    @meeting = Meeting.find(params[:meeting_id])
    @meeting.users << current_user
    @meeting.create_activity :go_to, owner: current_user
  end

  def destroy
    going_to = GoingTo.find(params[:id]).destroy
    @meeting = going_to.meeting
  end
end
