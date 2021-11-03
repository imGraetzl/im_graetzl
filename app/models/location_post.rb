class LocationPost < ApplicationRecord
  include Trackable
  extend FriendlyId
  friendly_id :title

  belongs_to :graetzl
  belongs_to :location

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true

  before_validation :set_graetzl, on: :create
  after_create :update_location_activity

  def edit_permission?(user)
    user && location.owned_by?(user)
  end

  def region_id
    location.region_id
  end

  def user_id
    location.user_id
  end

  private

  def set_graetzl
    self.graetzl = location.graetzl
  end

  def update_location_activity
    location.update(last_activity_at: created_at)
  end
end
