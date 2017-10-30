class ActivitiesController < ApplicationController

  def index
    @graetzl = Graetzl.find(params[:graetzl_id])
    @activity = @graetzl.activity.page(params[:page]).per(12)
    @decorated_activity = @graetzl.decorate_activity(@activity) if params[:page].blank?
  end

end
