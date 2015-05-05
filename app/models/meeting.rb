class Meeting < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name

  mount_uploader :cover_photo, CoverPhotoUploader

  # split datetime in date and time
  date_time_attribute :starts_at
  date_time_attribute :ends_at

  # associations
  has_and_belongs_to_many :graetzls

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address

  has_many :going_tos
  has_many :users, through: :going_tos

  has_and_belongs_to_many :categories

  # validations
  validates :name, presence: true
  validates :description, presence: true
  #validates :user_initialized, presence: true
  validate :starts_at_cannot_be_in_the_past
  validate :ends_at_cannot_be_before_starts_at
  #validate :graetzls_must_be_present

  private

    def starts_at_cannot_be_in_the_past
      if starts_at.present? && starts_at < Date.today
        errors.add(:starts_at, 'kann nicht in der Vergangenheit liegen')
      end
    end

    def ends_at_cannot_be_in_the_past
      if ends_at.present? && ends_at < Date.today
        errors.add(:ends_at, 'kann nicht in der Vergangenheit liegen')
      end
    end

    def ends_at_cannot_be_before_starts_at
      if starts_at.present? && ends_at.present? && ends_at < starts_at
        errors.add(:ends_at, 'kann nicht vor Beginn liegen')
      end
    end

    def graetzls_must_be_present
      if graetzls.size < 1
        errors.add(:graetzls, 'must at least be one')
      end
    end

end
