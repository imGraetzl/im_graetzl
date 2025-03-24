class CrowdPledge < ApplicationRecord
  include Trackable
  belongs_to :user, optional: true
  belongs_to :crowd_campaign
  belongs_to :crowd_reward, optional: true
  has_one :crowd_boost_charge
  belongs_to :comment, optional: true

  before_create :set_region
  before_save :normalize_email
  after_update :update_crowd_boost_charge, if: -> { crowd_boost_charge.present? && saved_change_to_status? }

  validates :email, format: { with: Devise.email_regexp }
  validates_presence_of :email, :contact_name
  validates :terms, acceptance: true
  validates :donation_amount, numericality: { greater_than_or_equal_to: 1 }, if: :donation_amount?
  validates :total_price, numericality: { less_than_or_equal_to: 25_000 }, if: :total_price?

  string_enum status: ["incomplete", "authorized", "processing", "debited", "failed", "canceled", "refunded"]

  scope :initialized, -> { where.not(status: :incomplete) }
  scope :donation, -> { where(crowd_reward_id: nil) }
  scope :reward, -> { where.not(crowd_reward_id: nil) }
  scope :visible, -> { where(anonym: false) }
  scope :anonym, -> { where(anonym: true) }

  scope :guest_newsletter, -> { where(guest_newsletter: true) }
  scope :guest_newsletter_recipients, -> { where(id: guest_newsletter.debited.uniq { |p| p.email }) }
  #scope :guest_newsletter_recipients, -> { where(id: guest_newsletter.debited.select("DISTINCT ON(crowd_pledges.email) crowd_pledges.id")) }

  def visible?
    !anonym
  end

  def user?
    user.present? && !user.guest?
  end

  def unsubscribe_code
    self.created_at.to_i
  end

  def donation_amount=(val)
    super if val.to_i >= 0
  end

  def crowd_boost_charge_amount=(val)
    super if val.to_i >= 0
  end

  def email=(val)
    super(val&.strip.presence)
  end

  def total_overall_price
    super || total_price + (crowd_boost_charge_amount || 0).to_i
  end  

  def calculate_price
    self.total_price = (crowd_reward&.amount || 0) + donation_amount.to_i
    boost_percentage = self.crowd_boost_charge_percentage.to_f
    self.crowd_boost_charge_amount = (self.total_price * (boost_percentage / 100.0)).round(2)
    self.crowd_boost_charge_amount = (self.crowd_boost_charge_amount / 0.25).ceil * 0.25
    self.total_overall_price = self.total_price + self.crowd_boost_charge_amount
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

  def normalize_email
    self.email = email.strip.downcase if email.present?
  end

  def update_crowd_boost_charge
    self.crowd_boost_charge.update(
      payment_status: self.status,
      debited_at: self.debited_at,
    )
  end

end
