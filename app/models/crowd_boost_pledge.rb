class CrowdBoostPledge < ApplicationRecord
  include Trackable

  belongs_to :crowd_campaign
  belongs_to :crowd_boost
  has_one :crowd_boost_slot, through: :crowd_campaign

  before_create :set_region

  enum :status, { authorized: "authorized", debited: "debited", canceled: "canceled" }

  scope :initialized, -> { where(status: [:authorized, :debited]) }

  private

  def set_region
    self.region_id = crowd_campaign.region_id
  end

end
