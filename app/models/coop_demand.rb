class CoopDemand < ApplicationRecord
  include Trackable

  extend FriendlyId
  friendly_id :slogan

  belongs_to :user
  belongs_to :location, optional: true
  belongs_to :coop_demand_category

  has_many :coop_demand_graetzls
  has_many :graetzls, through: :coop_demand_graetzls
  has_many :districts, -> { distinct }, through: :graetzls
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy

  enum coop_type: { demand: 0, offer: 1 }
  enum status: { enabled: 0, disabled: 1 }

  acts_as_taggable_on :keywords

  include AvatarUploader::Attachment(:avatar)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  scope :by_currentness, -> { order(last_activated_at: :desc) }

  LIFETIME_MONTHS = 6

  before_validation :smart_add_url_protocol, if: -> { website.present? }

  validates_presence_of :slogan, :demand_description, :personal_description, :avatar, :first_name, :last_name, :email, :coop_demand_category, :coop_type
  validate :has_one_graetzl_at_least

  after_update :destroy_activity_and_notifications, if: -> { disabled? && saved_change_to_status? }
  before_create :set_entire_region

  def to_s
    slogan
  end

  def activation_code
    self.created_at.to_i
  end

  def activate
    self.status = :enabled
    self.last_activated_at = Time.now
  end

  def refresh_activity
    if enabled? && last_activated_at < 15.days.ago
      update(last_activated_at: Time.now)
    end
  end

  private

  def smart_add_url_protocol
    unless website[/\Ahttp:\/\//] || website[/\Ahttps:\/\//]
      self.website = "https://#{website}"
    end
  end

  def has_one_graetzl_at_least
    if graetzl_ids.empty?
      errors.add(:graetzls, "muss ausgewählt werden")
    end
  end

  def set_entire_region
    self.entire_region = (self.graetzls&.length >= self.region.graetzls.count) ? true : false
  end

end
