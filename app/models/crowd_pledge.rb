class CrowdPledge < ApplicationRecord
  include Trackable
  belongs_to :user, optional: true
  belongs_to :crowd_campaign
  belongs_to :crowd_reward, optional: true

  before_create :set_region

  validates_presence_of :email, :contact_name
  validates :terms, acceptance: true
  validates :donation_amount, numericality: { greater_than_or_equal_to: 1 }, if: :donation_amount?
  validates :total_price, numericality: { less_than_or_equal_to: 25_000 }, if: :total_price?

  string_enum status: ["incomplete", "authorized", "processing", "debited", "failed", "canceled"]

  scope :initialized, -> { where.not(status: :incomplete) }
  scope :donation, -> { where(crowd_reward_id: nil) }
  scope :reward, -> { where.not(crowd_reward_id: nil) }
  scope :visible, -> { where(anonym: false) }
  scope :anonym, -> { where(anonym: true) }

  scope :guest_newsletter, -> { where(guest_newsletter: true) }
  scope :guest_newsletter_recipients, -> { where(id: guest_newsletter.debited.select("DISTINCT ON(crowd_pledges.email) crowd_pledges.id")) }

  def visible?
    !anonym
  end

  def guest_user?
    user_id.nil?
  end

  def unsubscribe_code
    self.created_at.to_i
  end

  def donation_amount=(val)
    super if val.to_i >= 0
  end

  def email=(val)
    super(val&.strip.presence)
  end

  def calculate_price
    self.total_price = (crowd_reward&.amount || 0) + donation_amount.to_i
  end

  def contact_name_and_type
    "#{contact_name} (#{email})"
  end

  def full_name
    contact_name
  end

  def first_name
    contact_name.split.first
  end

  def last_name
    contact_name.split(' ')[1..-1].join(' ')
  end

  private

  def set_region
    self.region_id = crowd_campaign.region_id
  end

end
