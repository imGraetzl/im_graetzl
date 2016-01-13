class NotificationSettingsController < ApplicationController
  before_action :authenticate_user!

  def toggle_website_notification
    type = params[:type]
    unless Notification.types.include?(type)
      render body: "unrecognized type: #{type} in order to toggle website_notification", status: :forbidden
      return
    end
    current_user.toggle_website_notification(type.constantize)

    render nothing: true
  end

  def change_mail_notification
    type = params[:type]
    unless Notification.types.include?(type)
      render body: "unrecognized type: #{type} in order to toggle website_notification", status: :forbidden
      return
    end

    if params[:interval] == 'off'
      [:immediate, :daily, :weekly].each do |i|
        current_user.disable_mail_notification(type.constantize, i)
      end
    else
      current_user.enable_mail_notification(type.constantize, params[:interval].to_sym)
    end
    render nothing: true
  end
end
