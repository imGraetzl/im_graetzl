class Location < ApplicationRecord
  include Trackable
  extend FriendlyId
  friendly_id :name

  attachment :avatar, type: :image
  attachment :cover_photo, type: :image
  include RefileShrineSynchronization
  before_save { write_shrine_data(:avatar) if avatar_id_changed? }
  before_save { write_shrine_data(:cover_photo) if cover_photo_id_changed? }

  acts_as_taggable_on :products

  belongs_to :user
  belongs_to :graetzl
  has_many :districts, through: :graetzl
  belongs_to :address, optional: true, autosave: true
  accepts_nested_attributes_for :address
  has_one :billing_address, dependent: :destroy
  accepts_nested_attributes_for :billing_address, allow_destroy: true, reject_if: :all_blank

  belongs_to :location_category
  has_many :location_posts, dependent: :destroy
  has_one :contact, dependent: :destroy
  accepts_nested_attributes_for :contact

  has_many :meetings
  has_many :upcoming_meetings, -> { upcoming }, class_name: "Meeting"
  has_many :room_offers
  has_many :tool_offers
  has_many :zuckerls, dependent: :destroy
  has_many :live_zuckerls, -> { live }, class_name: "Zuckerl"

  enum state: { pending: 0, approved: 1 }

  scope :online_shop, -> { joins(:contact).where("online_shop != ? AND online_shop != ?", "NIL", "") }

  validates_presence_of :name, :slogan, :description, :cover_photo, :avatar, :location_category

  before_create { |location| location.last_activity_at = Time.current }

  after_update :mailchimp_location_update, if: -> { approved?  }
  before_destroy :mailchimp_location_delete

  def self.include_for_box
    includes(:location_posts, :live_zuckerls, :address, :location_category, :upcoming_meetings)
  end

  def approve
    if pending?
      approved!
      create_activity(:create)
      UsersMailer.location_approved(self, self.user).deliver_now
    end
  end

  def to_s
    name
  end

  def reject
    (pending? && destroy) || nil
  end

  def can_create_meeting?(a_user)
    owned_by?(a_user)
  end

  def owned_by?(a_user)
    user_id.present? && user_id == a_user&.id
  end

  def onlineshop?
    self.contact.online_shop.present?
  end

  def full_address
    address&.street
  end

  def full_address=(value)
    return if full_address == value

    if value.present?
      resolver = AddressResolver.from_street(value)
      return if !resolver.valid?
      build_address if address.nil?
      self.address.assign_attributes(resolver.address_fields)
      self.graetzl = resolver.graetzl
    else
      self.address&.mark_for_destruction
    end
  end

  def address_description
    address&.description
  end

  def address_description=(value)
    if value.present?
      build_address if address.nil?
      address.description = value
    else
      self.address&.description = nil
    end
  end

  def actual_newest_post
    location_posts.select{|p| p.created_at > 8.weeks.ago}.max_by(&:created_at)
  end

  private

  def mailchimp_location_update
    MailchimpLocationUpdateJob.perform_later(self)
  end

  def mailchimp_location_delete
    MailchimpLocationDeleteJob.perform_later(self)
  end

end
