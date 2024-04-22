class CrowdBoostSlot < ApplicationRecord

  belongs_to :crowd_boost
  has_many :crowd_campaigns
  has_many :crowd_boost_pledges, through: :crowd_campaigns
  has_many :crowd_boost_slot_graetzls
  has_many :graetzls, through: :crowd_boost_slot_graetzls

  scope :active, -> { where("starts_at <= ?", Date.today).where("ends_at >= ?", Date.today) }
  scope :upcoming, -> { where("starts_at > ?", Date.today) }
  scope :expired, -> { where("ends_at < ?", Date.today) }

  before_destroy :can_destroy?
  validates_presence_of :starts_at, :ends_at, :amount_limit

  def active?
    Date.today >= starts_at && Date.today <= ends_at
  end

  def available?

  end

  def total_amount_initialized
    self.crowd_boost_pledges.initialized.sum(:amount)
  end

  def total_amount_pledged
    self.crowd_boost_pledges.debited.sum(:amount)
  end

  def balance
    amount_limit - total_amount_pledged
  end

  def calculate_boost(amount)
    if self.crowd_boost.boost_amount > 0
      self.crowd_boost.boost_amount
    else
      (amount / 100) * self.crowd_boost.boost_precentage
    end
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def runtime
    "#{I18n.localize(self.starts_at, format:'%d.%m.%y')} - #{I18n.localize(self.ends_at, format:'%d.%m.%y')}"
  end

  def title
    "#{self.runtime} - #{self.crowd_boost.title}"
  end

  def to_s
    title
  end

  private

  def self.in(region)
    joins(:graetzls).where(graetzls: {region_id: region.id}).distinct
  end

  def can_destroy?
    # abfrage ob es charges oder pledges gibt ...
    true
  end

end
