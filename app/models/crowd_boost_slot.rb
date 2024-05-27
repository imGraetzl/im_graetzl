class CrowdBoostSlot < ApplicationRecord

  belongs_to :crowd_boost
  has_many :crowd_campaigns
  has_many :crowd_boost_pledges, through: :crowd_campaigns
  has_many :crowd_boost_slot_graetzls
  has_many :graetzls, through: :crowd_boost_slot_graetzls

  scope :open, -> { where("starts_at <= ?", Date.today).where("ends_at >= ?", Date.today).order(:starts_at) }
  scope :active, -> { where("ends_at >= ?", Date.today).order(:ends_at) }
  scope :expired, -> { where("ends_at < ?", Date.today).order(:ends_at) }

  before_destroy :can_destroy?
  validates_presence_of :starts_at, :ends_at, :slot_amount_limit

  def open?
    Date.today >= starts_at && Date.today <= ends_at
  end

  def amount_limit_reached?(campaign)
    total_amount_initialized + calculate_boost(campaign) >= slot_amount_limit
  end

  def total_amount_initialized
    self.crowd_boost_pledges.initialized.sum(:amount)
  end

  def total_amount_pledged
    self.crowd_boost_pledges.debited.sum(:amount)
  end

  def balance
    slot_amount_limit - total_amount_pledged
  end

  def calculate_boost(campaign)
    if self.boost_amount && self.boost_amount > 0
      self.boost_amount
    else
      if ((campaign.funding_1_amount / 100) * self.boost_percentage) > self.boost_amount_limit
        self.boost_amount_limit
      else
        (campaign.funding_1_amount / 100) * self.boost_percentage
      end
    end
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def timerange
    "#{I18n.localize(self.starts_at, format:'%d. %B %Y')} - #{I18n.localize(self.ends_at, format:'%d. %B %Y')}"
  end

  def title
    "#{self.timerange} - #{self.crowd_boost.title}"
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
