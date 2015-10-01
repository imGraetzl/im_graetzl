class Location < ActiveRecord::Base
  include PublicActivity::Common
  extend FriendlyId

  # scopes
  scope :fit_for_meeting, -> { where(state: states[:approved], allow_meetings: true) }

  # macros
  friendly_id :name
  enum state: { pending: 0, approved: 1 }
  attachment :avatar, type: :image
  attachment :cover_photo, type: :image  

  # associations
  belongs_to :graetzl
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, allow_destroy: true
  has_one :contact, dependent: :destroy
  accepts_nested_attributes_for :contact
  has_many :location_ownerships, dependent: :destroy
  accepts_nested_attributes_for :location_ownerships, allow_destroy: true
  has_many :users, through: :location_ownerships
  has_many :categorizations, as: :categorizable
  accepts_nested_attributes_for :categorizations, allow_destroy: true
  has_many :categories, through: :categorizations
  has_many :meetings

  # validations
  validates :name, presence: true
  validates :graetzl, presence: true

  # callbacks
  before_destroy :destroy_activity_and_notifications, prepend: true

  def approve
    if pending? && approved!
      self.create_activity :approve
      return true
    end
    false
  end

  def reject
    if pending? && destroy
      return true
    end
    false
  end

  def owned_by(user)
    location_ownerships.basic.find_by_user_id(user)
  end


  private

  def destroy_activity_and_notifications
    activity = PublicActivity::Activity.where(trackable: self)
    notifications = Notification.where(activity: activity)
    notifications.destroy_all
    activity.destroy_all
  end
end
