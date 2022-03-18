class CrowdPledge < ApplicationRecord
  include Trackable
  belongs_to :user, optional: true
  belongs_to :crowd_campaign
  belongs_to :crowd_reward, optional: true

  before_create :set_region

  validates_presence_of :email, :contact_name

  enum status: { incomplete: 0, authorized: 1, debited: 2, failed: 3 }

  scope :complete, -> { where.not(status: :incomplete)}
  scope :visible, -> { where(anonym: false) }
  scope :anonym, -> { where(anonym: true) }

  PAYMENT_METHODS = ['card'].freeze

  def visible?
    !anonym
  end

  def guest_user?
    user_id.nil?
  end

  def donation_amount=(val)
    super if val.to_i >= 0
  end

  def calculate_price
    self.total_price = crowd_reward&.amount.to_i + donation_amount.to_i
  end

  private

  def set_region
    self.region_id = crowd_campaign.region_id
  end

end
