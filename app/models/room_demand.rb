class RoomDemand < ApplicationRecord
  include Trackable
  extend FriendlyId

  friendly_id :slogan

  belongs_to :user
  belongs_to :location, optional: true

  has_many :room_demand_categories
  has_many :room_categories, through: :room_demand_categories

  has_many :room_demand_graetzls
  has_many :graetzls, through: :room_demand_graetzls
  has_many :districts, -> { distinct }, through: :graetzls
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy

  enum demand_type: { seeking_room: 0, seeking_roommate: 1 }
  enum status: { enabled: 0, disabled: 1 }

  acts_as_taggable_on :keywords

  include AvatarUploader::Attachment(:avatar)

  scope :by_currentness, -> { order(last_activated_at: :desc) }

  before_validation :smart_add_url_protocol, if: -> { website.present? }

  validates_presence_of :slogan, :demand_description, :personal_description, :avatar, :first_name, :last_name, :email
  validate :has_one_category_at_least
  validate :has_one_graetzl_at_least # doesn't work for some reason

  LIFETIME_MONTHS = 5

  after_update :destroy_activity_and_notifications, if: -> { disabled? && saved_change_to_status? }
  before_create :set_entire_region

  generates_token_for :activation, expires_in: 7.days do
    created_at
  end

  def self.include_for_box
    includes(:room_categories)
  end

  def to_s
    slogan
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

  def has_one_category_at_least
    if room_categories.empty?
      errors.add(:room_categories, "braucht mindestens eine Kategorie")
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
