class CrowdBoostCharge < ApplicationRecord
  include Trackable

  belongs_to :crowd_boost
  belongs_to :user, optional: true
  belongs_to :zuckerl, optional: true
  belongs_to :room_booster, optional: true
  belongs_to :crowd_pledge, optional: true
  belongs_to :subscription_invoice, optional: true

  enum :charge_type, { general: "general", zuckerl: "zuckerl", room_booster: "room_booster", subscription_invoice: "subscription_invoice", crowd_pledge: "crowd_pledge", good_morning_date: "good_morning_date" }
  enum :payment_status, { incomplete: "incomplete", authorized: "authorized", processing: "processing", debited: "debited", failed: "failed", refunded: "refunded" }

  scope :expected, -> { where(payment_status: [:authorized, :processing]) }
  scope :initialized, -> { where.not(payment_status: :incomplete) }
  scope :debited_without_crowd_pledges, -> {
    where(payment_status: :debited).where.not(charge_type: :crowd_pledge)
  }
  
  def invoice
    bucket = Aws::S3::Resource.new.bucket('invoices.imgraetzl.at')
    bucket.object("#{Rails.env}/crowd_boost_charges/#{invoice_number}.pdf")
  end

  def title
     id
  end

  def full_name
    contact_name
  end

  private

end
