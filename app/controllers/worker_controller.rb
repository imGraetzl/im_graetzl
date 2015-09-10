class WorkerController < ApplicationController
  protect_from_forgery except: [ :daily_mail, :weekly_mail ]

  def daily_mail
    if ENV["ALLOW_WORKER"] == 'true' 
      User.where("daily_mail_notifications > 0").each do |u|
        SendMailNotificationJob.perform_later(u.id, 'daily')
      end
      Rails.logger.info "Send daily mail"
      render nothing: true, status: :ok
    else
      render body: "not allowed", status: :forbidden
    end
  end

  def weekly_mail
    if ENV["ALLOW_WORKER"] == 'true' 
      User.where("weekly_mail_notifications > 0").each do |u|
        SendMailNotificationJob.perform_later(u.id, 'weekly')
      end
      Rails.logger.info "Send weekly mail"
      render nothing: true, status: :ok
    else
      render body: "not allowed", status: :forbidden
    end
  end
end
