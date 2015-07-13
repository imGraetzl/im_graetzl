class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  attachment :avatar, type: :image
  enum role: [:admin, :business] 

  # associations
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  belongs_to :graetzl
  has_many :going_tos
  has_many :meetings, through: :going_tos
  has_many :posts
  has_many :comments
  has_many :notifications, dependent: :destroy

  # attributes
    # virtual attribute to login with username or email
    attr_accessor :login
  GENDER_TYPES = { weiblich: 1, männlich: 2, anders: 3 }

  # validations
  validates :graetzl, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :terms_and_conditions, acceptance: true
  #validates_integrity_of :avatar
  #validates_processing_of :avatar

  # class methods
  # overwrite devise authentication method to allow username OR email
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).
        where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).
        first
    else
      where(conditions.to_h).first
    end
  end

  def going_to?(meeting)
    meetings.include?(meeting)
  end

  def initiated?(meeting)
    going_to = going_tos.find_by_meeting_id(meeting)
    going_to && going_to.role == GoingTo::ROLES[:initiator]
  end

  def go_to(meeting, role=GoingTo::ROLES[:attendee])
    going_tos.create(meeting_id: meeting.id, role: role)
  end

  def enabled_website_notification?(type)
    enabled_website_notifications & Notification::TYPE_BITMASKS[type] > 0
  end

  def enable_website_notification(type)
    new_setting = enabled_website_notifications | Notification::TYPE_BITMASKS[type] 
    update_attribute(:enabled_website_notifications, new_setting)
  end

  def toggle_website_notification(type)
    new_setting = enabled_website_notifications ^ Notification::TYPE_BITMASKS[type] 
    update_attribute(:enabled_website_notifications, new_setting)
  end

  def website_notifications
    notifications.where(["bitmask & ? > 0", enabled_website_notifications])
  end

  def new_website_notifications_count
    website_notifications.where(seen: false).count
  end
end
