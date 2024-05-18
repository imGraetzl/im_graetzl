class CrowdBoostCharge < ApplicationRecord
  include Trackable

  belongs_to :crowd_boost
  belongs_to :user, optional: true
  belongs_to :crowd_pledge, optional: true

  string_enum payment_status: ["incomplete", "authorized", "processing", "debited", "failed", "refunded"]

  scope :initialized, -> { where.not(payment_status: :incomplete) }
  scope :crowd_pledge, -> { where.not(crowd_pledge_id: nil) }

  def self.next_invoice_number
    where("invoice_number IS NOT NULL").count + 1
  end

  def invoice
    bucket = Aws::S3::Resource.new.bucket('invoices.imgraetzl.at')
    bucket.object("#{Rails.env}/crowd_boost_charges/#{invoice_number}.pdf")
  end

  def full_name
    contact_name
  end

  private

end
