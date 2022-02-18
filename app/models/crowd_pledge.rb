class CrowdPledge < ApplicationRecord
  include Trackable
  belongs_to :user
  belongs_to :crowd_campaign
  belongs_to :crowd_reward, optional: true

  before_create :set_region

  PAYMENT_METHODS = ['card', 'eps'].freeze

  private

  def set_region
    self.region_id = crowd_campaign.region_id
  end

end
