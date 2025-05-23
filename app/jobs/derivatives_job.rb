# app/jobs/derivatives_job.rb
# Create Shrine Derivatives on S3
class DerivativesJob < ApplicationJob
  queue_as :default

  def perform(attacher_class, record_class, record_id, name)
    record = record_class.constantize.find(record_id)
    attacher = attacher_class.constantize.retrieve(model: record, name: name)
    attacher.create_derivatives
    attacher.atomic_persist
  end
end