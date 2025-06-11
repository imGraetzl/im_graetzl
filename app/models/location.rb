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
  has_many :location_menus, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy

  has_one :contact, dependent: :destroy
  accepts_nested_attributes_for :contact

  has_many :meetings
  has_many :upcoming_meetings, -> { upcoming }, class_name: "Meeting"
  has_one  :next_upcoming_meeting, -> { upcoming.order(:starts_at_date) }, class_name: "Meeting"
  has_many :room_offers
  has_many :room_demands
  has_many :tool_offers
  has_many :crowd_campaigns
  has_many :zuckerls
  has_many :live_zuckerls, -> { live }, class_name: 'Zuckerl'
  has_one  :latest_live_zuckerl, -> { live.order(created_at: :desc) }, class_name: 'Zuckerl'

  enum state: { pending: 0, approved: 1 }

  scope :online_shop, -> { where("online_shop_url != ''") }
  scope :goodie, -> { where("goodie != ''") }
  scope :menus, ->{ joins(:location_menus).merge(LocationMenu.upcoming) }
  scope :by_currentness, -> { order(last_activity_at: :desc) }

  before_validation :smart_add_url_protocol_online_shop, if: -> { online_shop_url.present? }
  before_validation :smart_add_url_protocol_website, if: -> { website_url.present? }

  validates_presence_of :name, :slogan, :description, :cover_photo, :avatar, :location_category
  validates :description, presence: true, length: { minimum: 250 }, on: :create

  before_create { |location| location.last_activity_at = Time.current }

  after_update :update_last_activity, if: -> { saved_change_to_goodie? }
  after_update :destroy_activity_and_notifications, if: -> { pending? && saved_change_to_state?}

  #def self.include_for_box
  #  includes(:user, :location_posts, :location_menus, :live_zuckerls, :location_category, :upcoming_meetings)
  #end

  def self.include_for_box
    preload(
      :user,
      :location_category,
      :latest_live_zuckerl,
      :next_upcoming_meeting,
      :location_menus,
      :location_posts
    )
  end

  def to_s
    name
  end

  def reject
    (pending? && destroy) || nil
  end

  def can_create_menu?
    self.location_category.name == "Gastronomie & Food"
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
    menus = location_menus.upcoming
    posts = location_posts.select{|p| p.created_at > 4.weeks.ago}
    (menus + posts).max_by(&:created_at)
  end

  def subscribed?
    user&.subscribed?
  end

  private

  def update_last_activity
    if self.approved? && self.goodie?
      self.last_activity_at = Time.current
      self.save
    end
  end

  def smart_add_url_protocol_online_shop
    unless online_shop_url[/\Ahttp:\/\//] || online_shop_url[/\Ahttps:\/\//]
      self.online_shop_url = "https://#{online_shop_url}"
    end
  end

  def smart_add_url_protocol_website
    unless website_url[/\Ahttp:\/\//] || website_url[/\Ahttps:\/\//]
      self.website_url = "https://#{website_url}"
    end
  end

end
