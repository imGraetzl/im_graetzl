class Location < ActiveRecord::Base
  has_paper_trail
  
  extend FriendlyId
  friendly_id :name
  attachment :avatar, type: :image
  attachment :cover_photo, type: :image

  # scopes
  scope :available, -> { where(state: [states[:basic], states[:managed]]) }

  # states
  enum state: { basic: 0, pending: 1, managed: 2 }

  # associations
  belongs_to :graetzl
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
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

  # class methods
  def self.reset_or_destroy(location)
    if location.previous_version
      location = location.previous_version
      location.save
    else
      location.destroy
    end
  end

  # instance methods
  def request_ownership(user)
    if user.business? && (pending? || managed?) && !users.include?(user)
      location_ownerships.create(user: user, state: LocationOwnership.states[:pending])
    end
  end

  def approve
    if pending? && managed!
      # update users
      return true
    end
    false
  end

  def reject
    if pending?
      Location.reset_or_destroy(self)
      # update users
      return true
    end
    false
  end

  def owned_by(user)
    location_ownerships.basic.find_by_user_id(user)
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
