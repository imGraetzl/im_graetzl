class NotificationSettingsController < ApplicationController
  before_action :authenticate_user!

  def toggle_website_notification
    type = params[:type]
    unless valid_notification_type?(type)
      render body: "unrecognized type: #{type} in order to toggle website_notification", status: :forbidden
      return
    end
    current_user.toggle_website_notification(type.constantize)
    render json: :ok
  end

  def change_mail_notification
    type = params[:type]
    unless valid_notification_type?(type)
      render body: "unrecognized type: #{type} in order to change mail_notification", status: :forbidden
      return
    end

    if params[:interval] == 'off'
      [:immediate, :daily, :weekly].each do |i|
        current_user.disable_mail_notification(type.constantize, i)
      end
    else
      current_user.enable_mail_notification(type.constantize, params[:interval].to_sym)
    end
    render json: :ok
  end

  private

  def valid_notification_type?(type)
    Notification.subclasses.map{|s| s.name}.include?(type)
  end
end
