class Meeting < ActiveRecord::Base
  mount_uploader :cover_photo, CoverPhotoUploader

  # split datetime in date and time
  date_time_attribute :starts_at
  date_time_attribute :ends_at

  # associations
  has_and_belongs_to_many :graetzls

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address

  belongs_to :user_initialized, class_name: 'User'
  
  has_and_belongs_to_many :users_going, class_name: 'User', join_table: 'meetings_users_going'

  # validations
  validates :name, presence: true
  validates :description, presence: true
  validates :user_initialized, presence: true
  validates :starts_at, presence: true
  validate :starts_at_cannot_be_in_the_past
  validate :graetzls_must_be_present

  private

    def starts_at_cannot_be_in_the_past
      if starts_at.present? && starts_at < Date.today
        errors.add(:starts_at, 'kann nicht in der Vergangenheit liegen')
      end
    end

    def graetzls_must_be_present
      if graetzls.size < 1
        errors.add(:graetzls, 'must at least be one')
      end
    end

end
