class EnergyOffer < ApplicationRecord
  include Trackable
  include Address

  extend FriendlyId
  friendly_id :title

  belongs_to :user
  belongs_to :location, optional: true
  has_many :energy_offer_categories
  has_many :energy_categories, through: :energy_offer_categories
  has_many :energy_offer_graetzls
  has_many :graetzls, through: :energy_offer_graetzls
  has_many :districts, -> { distinct }, through: :graetzls
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy

  enum status: { enabled: 0, disabled: 1 }
  string_enum energy_type: ["beg", "eeg_local", "eeg_regional", "unclear"]
  string_enum operation_state: ["progress", "active"]
  string_enum organization_form: ["verein", "genossenschaft", "other"]
  string_enum members_count: ["to_5", "5_to_10", "10_to_20", "20_to_50", "50_to"]

  acts_as_taggable_on :energy

  include AvatarUploader::Attachment(:avatar)
  include CoverImageUploader::Attachment(:cover_photo)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :energy_type, :title, :description, :project_goals, :energy_categories, :operation_state, :contact_name, :contact_email
  validate :has_one_graetzl_at_least

  before_validation :smart_add_url_protocol, if: -> { contact_website.present? }

  scope :by_currentness, -> { order(last_activated_at: :desc) }

  LIFETIME_MONTHS = 6

  after_update :destroy_activity_and_notifications, if: -> { disabled? }

  def to_s
    title
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

  def district
    self.graetzl.district
  end

  private

  def smart_add_url_protocol
    unless contact_website[/\Ahttp:\/\//] || contact_website[/\Ahttps:\/\//]
      self.contact_website = "https://#{contact_website}"
    end
  end

  def has_one_graetzl_at_least
    if graetzl_ids.empty?
      errors.add(:graetzl, "muss ausgewählt werden")
    end
  end

end
