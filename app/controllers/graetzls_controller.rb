class GraetzlsController < ApplicationController
  def index
    @graetzls = Graetzl.all
  end
  
  def show
    @graetzl = Graetzl.find(params[:id])
    user_activity = PublicActivity::Activity.where(owner: @graetzl.users).pluck(:id)
    meeting_activity = PublicActivity::Activity.where(trackable: @graetzl.meetings).pluck(:id)
    activity_ids = user_activity.concat(meeting_activity)
    @activities = PublicActivity::Activity.where(id: [activity_ids]) unless activity_ids.empty?
  end
end
