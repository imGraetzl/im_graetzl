class RoomOffer < ApplicationRecord
  include Trackable
  include Address

  extend FriendlyId
  friendly_id :slogan

  belongs_to :user
  belongs_to :graetzl
  has_many :districts, through: :graetzl
  belongs_to :location, optional: true

  has_many :room_offer_categories
  has_many :room_categories, through: :room_offer_categories
  has_many :room_offer_prices
  accepts_nested_attributes_for :room_offer_prices, allow_destroy: true, reject_if: :all_blank
  has_one :room_rental_price
  accepts_nested_attributes_for :room_rental_price, allow_destroy: true,
    reject_if: proc { |attrs| attrs['price_per_hour'].blank? }

  has_one :room_offer_availability
  accepts_nested_attributes_for :room_offer_availability, reject_if: :all_blank

  has_many :room_boosters
  has_many :room_rentals
  has_many :room_rental_slots, through: :room_rentals

  has_many :room_offer_waiting_users
  has_many :waiting_users, through: :room_offer_waiting_users, source: :user

  has_one :group
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy

  enum offer_type: { offering_room: 0, seeking_roommate: 1 }
  enum status: { enabled: 0, disabled: 1, occupied: 2 }

  acts_as_taggable_on :keywords

  include AvatarUploader::Attachment(:avatar)
  include CoverImageUploader::Attachment(:cover_photo)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :address_street, :slogan, :room_description, :owner_description, :tenant_description
  validates_presence_of :cover_photo, :first_name, :last_name, :email
  validates_presence_of :room_rental_price, if: :rental_enabled?
  validate :has_one_category_at_least

  before_validation :smart_add_url_protocol, if: -> { website.present? }
  after_destroy { MailchimpRoomDeleteJob.perform_later(user) }

  scope :by_currentness, -> { order(last_activated_at: :desc) }
  scope :rentable, -> { where(rental_enabled: true) }
  scope :boosted, -> { where(boosted: true) }

  LIFETIME_MONTHS = 6

  after_update :destroy_activity_and_notifications, if: -> { disabled? }

  def to_s
    slogan
  end

  def activation_code
    self.created_at.to_i
  end

  def available_days
    return [] if room_offer_availability.nil?
    (0..6).select{ |d| room_offer_availability.day_enabled?(d) }
  end

  def activate
    self.status = :enabled
    self.last_activated_at = Time.now
  end

  def refresh_activity
    if enabled? && last_activated_at < 15.days.ago && !boosted?
      update(last_activated_at: Time.now)
    end
  end

  def district
    self.graetzl.district
  end

  def subscribed?
    user&.subscribed?
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
end
