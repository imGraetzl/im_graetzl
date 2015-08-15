class Meeting < ActiveRecord::Base
  default_scope { order(starts_at_date: :asc) }

  include PublicActivity::Common
  extend FriendlyId
  friendly_id :name

  attachment :cover_photo, type: :image

  # associations
  belongs_to :graetzl
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  has_many :going_tos, dependent: :destroy
  has_many :users, through: :going_tos
  has_many :categorizations, as: :categorizable
  has_many :categories, through: :categorizations
  has_many :activities, as: :trackable, class_name: 'PublicActivity::Activity', dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  belongs_to :location

  # validations
  validates :name, presence: true
  validate :starts_at_date_cannot_be_in_the_past
  validate :ends_at_time_cannot_be_before_starts_at_time

  # class methods
  def self.upcoming
    m = Meeting.arel_table
    where(
      m[:starts_at_date].eq(nil).or(
        m[:starts_at_date].gt(Date.yesterday)))
  end

  def self.past
    m = Meeting.arel_table
    where(m[:starts_at_date].lt(Date.today))    
  end

  # instance methods
  def upcoming?
    if starts_at_date
      return starts_at_date > Date.yesterday
    end
    true
  end

  def past?
    if starts_at_date
      return starts_at_date < Date.today
    end
    false    
  end

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

    def ends_at_time_cannot_be_before_starts_at_time
      if starts_at_time && ends_at_time && ends_at_time < starts_at_time
        errors.add(:ends_at, 'kann nicht vor Beginn liegen')
      end
    end

end
