class GoingTosController < ApplicationController
  before_action :authenticate_user!

  def create
    @meeting = Meeting.find(params[:meeting_id])
    @meeting.users << current_user
    @meeting.create_activity :go_to, owner: current_user

    respond_to do |format|
      format.js
      format.json { render json: @meeting }
    end
  end

  def destroy
    going_to = GoingTo.find(params[:id])
    @meeting = going_to.meeting
    going_to.destroy
    @meeting.create_activity :left, owner: current_user

    respond_to do |format|
      format.js
      format.json { render json: @meeting }
    end
  end
end
