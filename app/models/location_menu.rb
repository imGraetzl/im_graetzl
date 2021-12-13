class LocationMenu < ApplicationRecord
  include Trackable

  belongs_to :graetzl
  belongs_to :location

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  scope :upcoming, -> {
    where("menu_to > :today", today: Date.yesterday).
    order(:menu_from) }

  validates_presence_of :menu_from, :menu_to, :description

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

  def title
    "Menüplan | #{I18n.localize(menu_from, format:'%A %d.%m')} - #{I18n.localize(menu_to, format:'%A %d.%m')}"
  end

  def time_range
    "#{I18n.localize(menu_from, format:'%A %d.%m')} - #{I18n.localize(menu_to, format:'%A %d.%m')}"
  end

  def notification_time_range
    [menu_from - 7.days, menu_to]
  end

  private

  def set_graetzl
    self.graetzl = location.graetzl
  end

  def update_location_activity
    location.update(last_activity_at: created_at)
  end
end
