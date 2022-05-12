class CrowdPledge < ApplicationRecord
  include Trackable
  belongs_to :user, optional: true
  belongs_to :crowd_campaign
  belongs_to :crowd_reward, optional: true

  before_create :set_region

  validates_presence_of :email, :contact_name
  validates :terms, acceptance: true
  validates :donation_amount, numericality: {greater_than_or_equal_to: 1}, if: :donation_amount?

  enum status: { incomplete: 0, authorized: 1, debited: 2, failed: 3, canceled: 4 }

  scope :potential, -> { where.not(status: :incomplete) }
  scope :complete, -> { where(status: [:authorized, :debited]) }
  scope :donation, -> { where(crowd_reward_id: nil) }
  scope :visible, -> { where(anonym: false) }
  scope :anonym, -> { where(anonym: true) }

  PAYMENT_METHODS = ['card', 'sepa_debit', 'sofort'].freeze

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
