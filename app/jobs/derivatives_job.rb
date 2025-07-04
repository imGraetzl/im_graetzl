# app/jobs/derivatives_job.rb
# Create Shrine Derivatives on S3
class DerivativesJob < ApplicationJob
  queue_as :shrine_derivatives

  def perform(attacher_class, record_class, record_id, name)
    record = record_class.constantize.find(record_id)
    attacher = attacher_class.constantize.from_model(record, name)
    attacher.create_derivatives
    begin
      attacher.atomic_persist
    rescue Shrine::AttachmentChanged => e
      Rails.logger.warn "[Shrine::AttachmentChanged] #{record_class}##{record_id} – Attachment wurde ersetzt, Derivate werden verworfen"
    end
  end
end