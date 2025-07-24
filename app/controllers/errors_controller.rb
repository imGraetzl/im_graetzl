class ErrorsController < ApplicationController

  def not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: 404 }
      format.json { render json: { error: 'Not Found' }, status: 404 }
      format.any  { head 404 }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render 'errors/internal_server_error', status: 500 }
      format.json { render json: { error: 'Internal Server Error' }, status: 500 }
      format.any  { head 500 }
    end
  end

end
