class ErrorsController < ApplicationController

  def not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: 404 }
      format.all { head 404 }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render 'errors/internal_server_error', status: 500 }
      format.all { head 500 }
    end
  end

end
