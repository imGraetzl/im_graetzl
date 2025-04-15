class ErrorsController < ApplicationController

  def not_found

    if request.path.include?("/attachments/") && request.path.include?("/fill/")
      Rails.logger.warn("[404 IMAGE] path=#{request.path} | ip=#{request.remote_ip} | ua=#{request.user_agent} | referer=#{request.referer}")
    end

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
