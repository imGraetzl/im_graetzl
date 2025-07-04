class CrowdPledge < ApplicationRecord
  include Trackable
  belongs_to :user, optional: true
  belongs_to :crowd_campaign
  belongs_to :crowd_reward, optional: true
  belongs_to :comment, optional: true

  # Charge Associations
  has_one :crowd_boost_charge
  belongs_to :crowd_boost, optional: true

  before_create :set_region
  before_save :normalize_email
  before_save :calculate_price_if_needed
  after_update :update_crowd_boost_charge, if: -> { crowd_boost_charge.present? && (saved_change_to_status? || saved_change_to_crowd_boost_charge_amount?) }

  validates :email, format: { with: Devise.email_regexp }
  validates_presence_of :email, :contact_name
  validates :terms, acceptance: true
  validates :donation_amount, numericality: { greater_than_or_equal_to: 1 }, if: :donation_amount?
  validates :total_price, numericality: { less_than_or_equal_to: 25_000 }, if: :total_price?

  enum status: { incomplete: "incomplete", authorized: "authorized", processing: "processing", debited: "debited", failed: "failed", canceled: "canceled", refunded: "refunded" }

  scope :initialized, -> { where.not(status: :incomplete) }
  scope :disputed, -> { where.not(disputed_at: nil).where(status: 'failed') }
  scope :donation, -> { where(crowd_reward_id: nil) }
  scope :reward, -> { where.not(crowd_reward_id: nil) }
  scope :charges, -> { where("crowd_boost_charge_amount > 0") }
  scope :visible, -> { where(anonym: false) }
  scope :anonym, -> { where(anonym: true) }

  scope :guest_newsletter, -> { where(guest_newsletter: true) }
  scope :guest_newsletter_recipients, -> { where(id: guest_newsletter.debited.uniq { |p| p.email }) }

  def visible?
    !anonym
  end

  def user?
    user.present? && !user.guest?
  end

  def has_charge?
    crowd_boost_charge_amount.to_i > 0
  end

  def saved_charge?
    crowd_boost_charge_amount.present?
  end

  def recently_authorized?
    authorized_at.present? && authorized_at >= 60.minutes.ago
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
    super || total_price + (crowd_boost_charge_amount || 0).to_d
  end

  def calculate_price
    self.total_price = (crowd_reward&.amount || 0).to_d + donation_amount.to_d
    self.total_overall_price = total_price + (crowd_boost_charge_amount || 0.0).to_d
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

  def calculate_price_if_needed
    if will_save_change_to_donation_amount? ||
       will_save_change_to_crowd_boost_charge_amount? ||
       will_save_change_to_crowd_reward_id?
      calculate_price
    end
  end

  def update_crowd_boost_charge
    if crowd_boost_charge_amount.to_d.zero?
      crowd_boost_charge&.destroy
      update_column(:crowd_boost_id, nil)
    else
      crowd_boost_charge&.update(
        payment_status: self.status,
        debited_at: self.debited_at,
        amount: self.crowd_boost_charge_amount
      )
    end
  end

end
