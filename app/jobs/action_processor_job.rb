# app/jobs/action_processor_job.rb
class ActionProcessorJob < ApplicationJob
  queue_as :action_processor

  def perform(subject, action, child = nil)
    ActionProcessor.new.track(subject, action, child)
  end
end
