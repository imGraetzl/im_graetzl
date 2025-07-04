Delayed::Worker.delay_jobs = true
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.raise_signal_exceptions = false
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.default_priority = 2
Delayed::Worker.queue_attributes = {
  'crowd_pledge_charge' => { priority: 0 },
  'action-processor' => { priority: 1 },
  'shrine_derivatives' => { priority: 3 },
  'mailchimp' => { priority: 4 },
  'summary-mails' => { priority: 5 }
}