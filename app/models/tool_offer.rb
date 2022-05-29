class ToolOffer < ApplicationRecord
  include Trackable
  include Address

  extend FriendlyId
  friendly_id :title

  belongs_to :user
  belongs_to :graetzl
  belongs_to :location, optional: true

  belongs_to :tool_category, optional: true

  has_many :tool_rentals
  has_many :comments, as: :commentable, dependent: :destroy

  enum status: { enabled: 0, disabled: 1, deleted: 2 }

  acts_as_taggable_on :keywords

  include CoverImageUploader::Attachment(:cover_photo)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :title, :description, :address_street, :tool_category_id, :cover_photo, :price_per_day, :iban

  before_save :check_discounts

  scope :non_deleted, -> { where.not(status: :deleted) }
  scope :by_currentness, -> { order(created_at: :desc) }

  after_update :destroy_activity_and_notifications, if: -> { disabled? }

  def self.include_for_box
    includes(:user, :tool_category)
  end

  def to_s
    title
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def daily_price(days)
    if days >= 7
      price_per_day * (100 - weekly_discount.to_i) / 100
    elsif days >= 2
      price_per_day * (100 - two_day_discount.to_i) / 100
    else
      price_per_day
    end
  end

  private

  def check_discounts
    if weekly_discount.to_i < two_day_discount.to_i
      self.weekly_discount = two_day_discount
    end
  end

end
