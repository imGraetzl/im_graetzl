require 'tempfile'
require 'rake'

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

  def backup
    if ENV["ALLOW_WORKER"] == 'true'
      dump = Tempfile.new('dump')
      dump_cmd = "PGPASSWORD=#{ENV['DB_PASSWORD']} pg_dumpall -h #{ENV['DB_HOST']} -U #{ENV['DB_USERNAME']} -p #{ENV['DB_PORT']} > #{dump.path}"
      Rails.logger.info dump_cmd
      Rails.logger.info `#{dump_cmd}`
      Aws.config[:credentials] = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_KEY'])
      Aws.config[:region] = 'eu-central-1'
      s3 = Aws::S3::Resource.new
      s3.bucket('im-graetzl-db-backups').object("#{ENV['DB_NAME']}_#{Time.now.strftime("%d-%m-%Y-%H:%M")}").upload_file(dump.path)
      render nothing: true, status: :ok
    else
      render body: "not allowed", status: :forbidden
    end
  end

  def truncate_db
    if ENV['ALLOW_WORKER'] == 'true'
      ImGraetzl::Application.load_tasks
      Rake::Task['db:truncate'].invoke
      render nothing: true, status: :ok
    else
      render body: 'not allowed', status: :forbidden
    end
  end

  def truncate_eb
    if (ENV['ALLOW_WORKER'] == 'true') && Rails.env.staging?
      ImGraetzl::Application.load_tasks
      Rake::Task['eb:truncate'].invoke
      render nothing: true, status: :ok
    else
      render body: 'not allowed', status: :forbidden
    end
  end
end
