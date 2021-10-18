class Location < ApplicationRecord
  include Trackable
  include Address

  extend FriendlyId
  friendly_id :name
  acts_as_taggable_on :products

  include AvatarUploader::Attachment(:avatar)
  include CoverImageUploader::Attachment(:cover_photo)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  belongs_to :user
  belongs_to :graetzl
  has_many :districts, through: :graetzl
  has_one :billing_address, dependent: :destroy
  accepts_nested_attributes_for :billing_address, allow_destroy: true, reject_if: :all_blank

  belongs_to :location_category
  has_many :location_posts, dependent: :destroy
  has_many :comments, through: :location_posts

  has_one :contact, dependent: :destroy
  accepts_nested_attributes_for :contact

  has_many :meetings
  has_many :upcoming_meetings, -> { upcoming }, class_name: "Meeting"
  has_many :room_offers
  has_many :tool_offers
  has_many :zuckerls, dependent: :destroy
  has_many :live_zuckerls, -> { live }, class_name: "Zuckerl"

  enum state: { pending: 0, approved: 1 }

  scope :online_shop, -> { where("online_shop_url != ''") }
  scope :goodie, -> { where("goodie != ''") }

  validates_presence_of :name, :slogan, :description, :cover_photo, :avatar, :location_category

  before_create { |location| location.last_activity_at = Time.current }

  after_update :mailchimp_location_update, if: -> { approved?  }
  before_destroy :mailchimp_location_delete

  def self.include_for_box
    includes(:location_posts, :live_zuckerls, :location_category, :upcoming_meetings)
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

  def online_shop?
    self.online_shop_url.present?
  end

  def goodie?
    self.goodie.present?
  end

  def actual_newest_post
    location_posts.select{|p| p.created_at > 4.weeks.ago}.max_by(&:created_at)
  end

  private

  def mailchimp_location_update
    MailchimpLocationUpdateJob.perform_later(self)
  end

  def mailchimp_location_delete
    MailchimpLocationDeleteJob.perform_later(self)
  end

end
