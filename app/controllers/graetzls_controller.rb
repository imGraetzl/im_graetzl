class GraetzlsController < ApplicationController
  def index
    @graetzls = Graetzl.all
  end
  
  def show
    @graetzl = Graetzl.find(params[:id])
    @activities = @graetzl.activity
    @meetings = @graetzl.meetings.upcoming.where.not(starts_at_date: nil).first(2)
  end
end
