class EnergyDemand < ApplicationRecord
  include Trackable
  include Address

  extend FriendlyId
  friendly_id :title

  belongs_to :user
  has_many :energy_demand_categories
  has_many :energy_categories, through: :energy_demand_categories
  has_many :energy_demand_graetzls
  has_many :graetzls, through: :energy_demand_graetzls
  has_many :districts, -> { distinct }, through: :graetzls
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy

  enum status: { enabled: 0, disabled: 1 }
  string_enum energy_type: ["beg", "eeg_local", "eeg_regional", "unclear"]
  string_enum orientation_type: ["small", "big", "poor"]
  string_enum organization_form: ["verein", "genossenschaft", "other"]

  acts_as_taggable_on :energy

  include AvatarUploader::Attachment(:avatar)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :energy_type, :title, :description, :energy_categories, :contact_name, :contact_email
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
