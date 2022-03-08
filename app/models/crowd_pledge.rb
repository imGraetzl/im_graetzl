class CrowdPledge < ApplicationRecord
  include Trackable
  belongs_to :user, optional: true
  belongs_to :crowd_campaign
  belongs_to :crowd_reward, optional: true

  before_create :set_region

  validates_presence_of :email, :contact_name

  enum status: { incomplete: 0, authorized: 1, debited: 2 }
  scope :visible, -> { where(anonym: false) }
  scope :anonym, -> { where(anonym: true) }

  PAYMENT_METHODS = ['card', 'eps'].freeze

  def visible?
    !anonym
  end

  def total_price
    if !crowd_reward.nil? && !amount.nil?
      crowd_reward.amount + amount
    else
      amount || crowd_reward&.amount || 0
    end
  end

  private

  def set_region
    self.region_id = crowd_campaign.region_id
  end

end
