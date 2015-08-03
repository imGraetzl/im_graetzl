class Location < ActiveRecord::Base
  #include ActiveModel::Dirty
  has_paper_trail
  
  extend FriendlyId
  friendly_id :name
  attachment :avatar, type: :image
  attachment :cover_photo, type: :image

  # scopes
  scope :available, -> { where(state: [states[:basic], states[:managed]]) }
  #scope :all_pending, -> { where(state: [states[:pending], states[:requested]]) }

  # states
  enum state: { basic: 0, pending: 1, managed: 2 }
  # include AASM
  # enum state: { requested: 0, basic: 1, pending: 2, managed: 3, rejected: 4 }
  # aasm column: :state do
  #   state :basic, initial: true
  #   state :requested
  #   state :pending
  #   state :managed
  #   state :rejected

  #   event :request do
  #     transitions from: :basic, to: :requested
  #   end

  #   event :adopt do
  #     transitions from: :basic, to: :pending
  #   end

  #   event :approve, after: :update_ownerships do
  #     transitions from: :pending, to: :managed
  #     transitions from: :requested, to: :managed
  #     transitions from: :rejected, to: :managed
  #   end

  #   event :reject do
  #     transitions from: :requested, to: :rejected
  #     transitions from: :pending, to: :basic, after: :reset_attributes
  #   end
  # end

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
  def request_ownership(user)
    if user.business? && (pending? || managed?)
      location_ownerships.create(user: user, state: LocationOwnership.states[:requested])
    end
  end

  private

    # def update_ownerships
    #   location_ownerships.pending.each do |ownership|
    #     ownership.approve!
    #   end
    # end

    # def reset_attributes
    #   previous_changes.slice(:name, :slogan, :description, :cover_photo_id, :cover_photo_content_type, :avatar_id, :avatar_photo_content_type).each do |key, value|
    #     self[key.to_sym] = value.first
    #   end
    #   address.previous_changes.slice(:street_name, :street_number, :zip, :city, :coordinates).each do |key, value|
    #     self.address[key.to_sym] = value.first
    #   end
    #   contact.previous_changes.slice(:website, :email, :phone).each do |key, value|
    #     self.contact[key.to_sym] = value.first
    #   end
    # end
end
