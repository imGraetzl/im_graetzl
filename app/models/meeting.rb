class Meeting < ActiveRecord::Base
  include PublicActivity::Common
  extend FriendlyId

  # scopes
  scope :upcoming, -> { where("(starts_at_date > ?)
                              OR
                              (starts_at_date IS NULL)", Date.yesterday)
                        .order(:starts_at_date) }
  scope :past, -> { where('starts_at_date < ?', Date.today).
                    order(starts_at_date: :desc) }
  scope :paginate_with_padding, ->(page) { page(page)
                                            .per(page == 1 ? 8 : 9)
                                            .padding(page == 1 ? 0 : -1) }

  # scopes primarily used for users
  scope :initiated, -> { includes(:going_tos, :graetzl)
                        .where('going_tos.role = ?', GoingTo::roles[:initiator]).references(:going_tos)
                        .order(starts_at_date: :desc) }
  scope :attended, -> { includes(:going_tos, :graetzl)
                        .where('going_tos.role = ?', GoingTo::roles[:attendee]).references(:going_tos)
                        .order(starts_at_date: :desc) }

  # macros
  friendly_id :name
  attachment :cover_photo, type: :image
  enum state: { basic: 0, cancelled: 1 }

  # associations
  belongs_to :graetzl
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  has_many :going_tos, dependent: :destroy
  accepts_nested_attributes_for :going_tos, allow_destroy: true
  has_many :users, through: :going_tos
  has_many :categorizations, as: :categorizable
  accepts_nested_attributes_for :categorizations, allow_destroy: true
  has_many :categories, through: :categorizations
  has_many :activities, as: :trackable, class_name: 'PublicActivity::Activity', dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  belongs_to :location

  # validations
  validates :name, presence: true
  validates :graetzl, presence: true
  validate :starts_at_date_cannot_be_in_the_past, on: :create

  # callbacks
  before_destroy :destroy_activity_and_notifications, prepend: true

  # instance methods
  def initiator
    going_to = going_tos.initiator.last
    going_to.user if going_to
  end

  private

  def starts_at_date_cannot_be_in_the_past
    if starts_at_date && starts_at_date < Date.today
      errors.add(:starts_at, 'kann nicht in der Vergangenheit liegen')
    end
  end

  def destroy_activity_and_notifications
    activity = PublicActivity::Activity.where(trackable: self)
    notifications = Notification.where(activity: activity)
    notifications.destroy_all
    activity.destroy_all
  end
end
