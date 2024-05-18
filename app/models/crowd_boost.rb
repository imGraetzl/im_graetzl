class CrowdBoost < ApplicationRecord

  include AvatarUploader::Attachment(:avatar)
  extend FriendlyId
  friendly_id :title, :use => :history

  has_many :crowd_boost_charges
  has_many :crowd_boost_pledges
  has_many :crowd_boost_slots
  has_many :crowd_campaigns, through: :crowd_boost_slots

  enum status: { enabled: 0, disabled: 1 }

  before_destroy :can_destroy?
  validates_presence_of :title

  def total_amount_charged
    self.crowd_boost_charges.debited.sum(:amount)
  end

  def total_amount_pledged
    self.crowd_boost_pledges.debited.sum(:amount)
  end

  def balance
    total_amount_charged - total_amount_pledged
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def to_s
    title
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
    where(id: region.crowd_boost_ids)
  end

  def can_destroy?
    # abfrage ob es charges oder pledges gibt ...
    true
  end

end
