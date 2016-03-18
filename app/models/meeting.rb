class Meeting < ActiveRecord::Base
  include Trackable
  extend FriendlyId

  scope :by_currentness, -> {
    basic.
    order('CASE WHEN starts_at_date > now() THEN 0 WHEN starts_at_date IS NULL THEN 1 ELSE 2 END').
    order('(CASE WHEN starts_at_date >= now() THEN starts_at_date END) ASC,
            (CASE WHEN starts_at_date < now() THEN starts_at_date END) DESC')
  }

  scope :upcoming, -> { where("(starts_at_date > ?)
                              OR
                              (starts_at_date IS NULL)", Date.yesterday)
                        .order(:starts_at_date) }
  scope :past, -> { where('starts_at_date < ?', Date.today).
                    order(starts_at_date: :desc) }

  # scopes primarily used for users
  scope :initiated, -> { includes(:going_tos, :graetzl)
                        .where('going_tos.role = ?', GoingTo::roles[:initiator]).references(:going_tos)
                        .order(starts_at_date: :desc) }
  scope :attended, -> { includes(:going_tos, :graetzl)
                        .where('going_tos.role = ?', GoingTo::roles[:attendee]).references(:going_tos)
                        .order(starts_at_date: :desc) }

  friendly_id :name
  attachment :cover_photo, type: :image
  enum state: { basic: 0, cancelled: 1 }

  belongs_to :graetzl
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  has_many :going_tos, dependent: :destroy
  accepts_nested_attributes_for :going_tos, allow_destroy: true
  has_many :users, through: :going_tos
  has_many :categorizations, as: :categorizable
  accepts_nested_attributes_for :categorizations, allow_destroy: true
  has_many :categories, through: :categorizations
  has_many :comments, as: :commentable, dependent: :destroy
  belongs_to :location

  validates :name, presence: true
  validates :graetzl, presence: true
  validate :starts_at_date_cannot_be_in_the_past, on: :create

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
end
