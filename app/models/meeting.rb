class Meeting < ActiveRecord::Base
  include PublicActivity::Common
  extend FriendlyId
  friendly_id :name

  mount_uploader :cover_photo, CoverPhotoUploader

  # associations
  has_and_belongs_to_many :graetzls

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address

  has_many :going_tos, dependent: :destroy
  has_many :users, through: :going_tos

  has_and_belongs_to_many :categories

  # validations
  validates :name, presence: true
  validate :starts_at_date_cannot_be_in_the_past
  validate :ends_at_time_cannot_be_before_starts_at_time

  # instance methods
  def upcoming?
    if starts_at_date
      return starts_at_date > Date.today
    end
    true
  end

  def past?
    if starts_at_date
      return starts_at_date < Date.today
    end
    false    
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
