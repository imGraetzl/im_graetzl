class Crowdfunding < ApplicationRecord
  include Trackable
  include Address

  extend FriendlyId
  friendly_id :title

  belongs_to :user
  belongs_to :graetzl
  belongs_to :district, optional: true
  belongs_to :location, optional: true
  belongs_to :room_offer, optional: true

  has_and_belongs_to_many :crowd_categories

  has_many :crowd_rewards
  accepts_nested_attributes_for :crowd_rewards, allow_destroy: true, reject_if: :all_blank

  has_many :crowd_donations
  accepts_nested_attributes_for :crowd_donations, allow_destroy: true, reject_if: :all_blank

  has_many :comments, as: :commentable, dependent: :destroy

  enum status: { draft: 0, pending: 1, approved: 2 }
  enum billable: { no_bill: 0, bill: 1, bill_with_tax: 2 }

  include CoverImageUploader::Attachment(:cover_photo)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :title, :graetzl

  def to_s
    title
  end

  def graetzl=(value)
    super
    self.district ||= value.district if value.present?
  end

  private

  def has_one_category_at_least
    if crowdfunding_categories.empty?
      errors.add(:crowdfunding_categories, "braucht mindestens eine Kategorie")
    end
  end
end
