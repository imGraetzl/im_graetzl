class Meeting < ActiveRecord::Base

  # split datetime in date and time
  date_time_attribute :start
  date_time_attribute :end

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
  validates :start, presence: true
  validate :start_date_cannot_be_in_the_past
  validate :graetzls_must_be_present

  private

    def start_date_cannot_be_in_the_past
      if start.present? && start < Date.today
        errors.add(:start, "can't be in the past")
      end
    end

    def graetzls_must_be_present
      if graetzls.size < 1
        errors.add(:graetzls, 'must at least be one')
      end
    end

end
