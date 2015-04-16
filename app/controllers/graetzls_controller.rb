class GraetzlsController < ApplicationController
  def show
    @graetzl = Graetzl.find(params[:id])
  end
end
