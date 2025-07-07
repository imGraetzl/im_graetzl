Rails.application.config.active_job.queue_adapter = :delayed_job
Delayed::Worker.delay_jobs = Rails.env.staging? || Rails.env.production?
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.raise_signal_exceptions = false
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.default_priority = 1
Delayed::Worker.queue_attributes = {
  'action-processor' => { priority: 0 },
  'shrine_derivatives' => { priority: 1 },
  'mailchimp' => { priority: 2 },
  'summary-mails' => { priority: 3 }
}
Rails.application.config.active_job.rescue_from Errno::ECONNRESET do |exception|
  if executions >= 3
    logger.warn "Job failed with Errno::ECONNRESET after maximum retries, but it's likely the email was sent. Discarding job. Error: #{exception.message}"
    discard
  else
    logger.warn "Job failed with Errno::ECONNRESET (attempt #{executions}/3), retrying. Error: #{exception.message}"
    retry_job(wait: 30.seconds)
  end
end