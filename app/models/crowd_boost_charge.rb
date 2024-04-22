class CrowdBoostCharge < ApplicationRecord
  include Trackable

  belongs_to :crowd_boost
  belongs_to :user, optional: true
  belongs_to :crowd_pledge, optional: true

  string_enum payment_status: ["incomplete", "authorized", "processing", "debited", "failed", "refunded"]

  scope :initialized, -> { where.not(payment_status: :incomplete) }
  scope :crowd_pledge, -> { where.not(crowd_pledge_id: nil) }

  private

end
