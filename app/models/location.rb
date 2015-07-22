class Location < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  attachment :avatar, type: :image
  attachment :cover_photo, type: :image

  # states
  include AASM
  enum state: { basic: 0, pending: 1, approved: 2 }
  aasm column: :state do
    state :basic, initial: true
    state :pending
    state :approved

    event :adopt do
      transitions from: :basic, to: :pending, after: :notify_user
    end

    event :approve do
      transitions from: :pending, to: :approved, after: :notify_user
    end
  end

  # associations
  belongs_to :graetzl
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  has_one :contact, dependent: :destroy
  accepts_nested_attributes_for :contact
  has_many :location_ownerships, dependent: :destroy
  has_many :users, through: :location_ownerships

  # validations
  validates :name, presence: true

  # instance methods
  def notify_user(user)
    puts 'yeah yeah yeah yeah yeah yeah'
    puts user.username
  end

  def request_ownership(user)
    # do sth
  end
end
