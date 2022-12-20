class NotificationSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_valid_type

  def toggle_website_notification
    notification_type = params[:type].constantize
    current_user.toggle_website_notification(notification_type)
    render json: :ok
  end

  def change_mail_notification
    if params[:type] == 'newsletter'
      newsletter_state = ActiveModel::Type::Boolean.new.cast(params[:interval])
      current_user.update(newsletter: newsletter_state)
    elsif params[:interval] == 'off'
      current_user.disable_all_mail_notifications(params[:type].constantize)
    else
      current_user.enable_mail_notification(params[:type].constantize, params[:interval].to_sym)
    end
    render json: :ok
  end

  private

  def check_valid_type
    if !(Notifications::AllTypes.map(&:name).include?(params[:type]) || ["newsletter"].include?(params[:type]))
      render body: "unrecognized type: #{params[:type]}", status: :forbidden
    end
  end

end
