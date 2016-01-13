class User < ActiveRecord::Base
  include PublicActivity::Common
  extend FriendlyId

  # macros
  attr_accessor :login # virtual attribute to login with username or email
  friendly_id :username
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  attachment :avatar, type: :image
  attachment :cover_photo, type: :image
  enum role: { admin: 0, business: 1 }

  # associations
  belongs_to :graetzl
  has_one :curator, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy
  has_many :going_tos, dependent: :destroy
  has_many :meetings, through: :going_tos
  has_many :posts, as: :author, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :location_ownerships, dependent: :destroy
  has_many :locations, through: :location_ownerships
  has_many :wall_comments, as: :commentable, class_name: Comment, dependent: :destroy
  accepts_nested_attributes_for :address

  # validations
  validates :graetzl, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :terms_and_conditions, acceptance: true

  # callbacks
  before_destroy :destroy_activity_and_notifications, prepend: true
  before_validation { self.username.squish! if self.username }

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


  # website notifications ->

  def enabled_website_notification?(type)
    enabled_website_notifications & Notification::TYPES[type][:bitmask] > 0
  end

  # TODO only used in specs -> not necessary?
  def enable_website_notification(type)
    new_setting = enabled_website_notifications | type::BITMASK
    update_attribute(:enabled_website_notifications, new_setting)
  end

  def toggle_website_notification(type)
    new_setting = enabled_website_notifications ^ Notification::TYPES[type][:bitmask]
    update_attribute(:enabled_website_notifications, new_setting)
  end

  def website_notifications
    notifications.where(["bitmask & ? > 0", enabled_website_notifications]).where(display_on_website: true)
  end

  def new_website_notifications_count
    website_notifications.where(seen: false).count
  end


  # mail notifications ->

  def mail_notifications(interval)
    notifications.where(["bitmask & ? > 0", send("#{interval}_mail_notifications".to_sym)])
  end

  def enabled_mail_notification?(type, interval)
    send("#{interval}_mail_notifications".to_sym) & Notification::TYPES[type][:bitmask] > 0
  end

  def enable_mail_notification(type, interval)
    [ :immediate, :daily, :weekly ].each do |i|
      disable_mail_notification(type, i)
    end

    new_setting = send("#{interval}_mail_notifications".to_sym) | Notification::TYPES[type][:bitmask]
    update_attribute("#{interval}_mail_notifications".to_sym, new_setting)
  end

  def disable_mail_notification(type, interval)
    mask = "11111111111111".to_i(2) ^ Notification::TYPES[type][:bitmask]
    new_setting = send("#{interval}_mail_notifications".to_sym) & mask
    update_attribute("#{interval}_mail_notifications".to_sym, new_setting)
  end


  # digest mails ->

  def notifications_of_the_day
    notifications.where(["bitmask & ? > 0", daily_mail_notifications]).
                      where("created_at >= NOW() - interval '5 minutes'").
                      where(sent: false)
  end

  def notifications_of_the_week
    notifications.where(["bitmask & ? > 0", weekly_mail_notifications]).
                      where("created_at >= NOW() - interval '30 minutes'").
                      where(sent: false)
  end


  private

  def destroy_activity_and_notifications
    activity = PublicActivity::Activity.where(owner: self)
    notifications = Notification.where(activity: activity)
    notifications.destroy_all
    activity.destroy_all
  end
end
