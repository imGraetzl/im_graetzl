class GraetzlsController < ApplicationController
  def index
    @graetzls = Graetzl.all
  end
  
  def show
    @graetzl = Graetzl.find(params[:id])
    @activities = PublicActivity::Activity.where(owner: @graetzl.users)
  end
end
