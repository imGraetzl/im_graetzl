class CrowdBoost < ApplicationRecord

  include AvatarUploader::Attachment(:avatar)
  extend FriendlyId
  friendly_id :title, :use => :history

  has_many :crowd_boost_charges
  has_many :crowd_boost_pledges
  has_many :crowd_boost_slots
  has_many :crowd_campaigns, through: :crowd_boost_slots

  enum status: { enabled: 0, disabled: 1 }

  enum chargeable_status: { charge_enabled: "charge_enabled" }

  before_save :remove_blank_region_ids
  before_destroy :can_destroy?
  validates_presence_of :title

  scope :pledge_charge, -> { where(pledge_charge: true) }

  def chargeable?
    charge_enabled?
  end

  def balance
    total_amount_charged - total_amount_pledged
  end

  def total_amount_charged
    self.crowd_boost_charges.debited.sum(:amount)
  end

  def total_amount_pledged
    self.crowd_boost_pledges.debited.sum(:amount)
  end

  def charges_expected
    self.crowd_boost_charges.expected.sum(:amount)
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def to_s
    title
  end

  def region
    region_id = Array(self.region_ids).first
    Region.get(region_id) if region_id.present?
  end

  def open_slot(region = nil)
    if region
      crowd_boost_slots.in(region).currently_open.first
    else
      crowd_boost_slots.currently_open.first
    end
  end

  def next_slot(region = nil)
    if region
      crowd_boost_slots.in(region).active.first
    else
      crowd_boost_slots.active.first
    end
  end

  def prev_slot(region = nil)
    if region
      crowd_boost_slots.in(region).expired.last
    else
      crowd_boost_slots.expired.last
    end
  end

  private

  def self.in(region)
    where(":region_ids = ANY (region_ids)", region_ids: region.id)
  end

  def remove_blank_region_ids
    self.region_ids.reject!(&:blank?).to_s
  end

  def can_destroy?
    if self.crowd_campaigns.boost_initialized.any? || self.crowd_boost_charges.initialized.any? || self.crowd_boost_pledges.initialized.any?
      throw :abort
    end
  end

end
