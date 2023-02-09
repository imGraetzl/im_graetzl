class User < ApplicationRecord
  include Address
  include Trackable
  include UserNotifiable

  extend FriendlyId
  friendly_id :username

  attr_accessor :login # virtual attribute to login with username or email

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :masqueradable

  enum role: { admin: 0, beta: 1 }

  include AvatarUploader::Attachment(:avatar)
  include CoverImageUploader::Attachment(:cover_photo)

  belongs_to :graetzl, counter_cache: true
  has_many :districts, through: :graetzl
  has_many :user_graetzls
  has_many :favorite_graetzls, through: :user_graetzls, source: :graetzl

  has_many :subscriptions
  has_many :subscription_invoices

  has_many :initiated_meetings, class_name: 'Meeting'
  has_many :going_tos, dependent: :destroy
  has_many :meeting_additional_dates, through: :going_tos, source: :meeting
  has_many :attended_meetings, through: :going_tos, source: :meeting

  has_many :comments, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :zuckerls, through: :locations
  has_many :coop_demands, dependent: :destroy
  has_many :room_offers
  has_many :room_demands, dependent: :destroy
  has_many :room_boosters
  has_many :room_rentals
  has_many :owned_room_rentals, through: :room_offers, source: :room_rentals
  has_many :tool_demands, dependent: :destroy
  has_many :tool_offers
  has_many :owned_tool_rentals, through: :tool_offers, source: :tool_rentals
  has_many :tool_rentals
  has_many :crowd_campaigns
  has_many :crowd_pledges

  has_and_belongs_to_many :business_interests
  belongs_to :location_category, optional: true

  has_many :group_join_requests
  has_many :group_users
  has_many :groups, through: :group_users
  has_many :discussions
  has_many :discussion_followings

  has_many :user_message_thread_members
  has_many :user_message_threads, through: :user_message_thread_members

  has_many :wall_comments, as: :commentable, class_name: "Comment", dependent: :destroy

  has_many :favorite_users, as: :favoritable, class_name: "Favorite", dependent: :destroy
  has_many :favorites, inverse_of: :user

  has_one :billing_address, dependent: :destroy
  accepts_nested_attributes_for :billing_address, reject_if: :all_blank

  before_validation :smart_add_url_protocol, if: -> { website.present? }

  validates :email, presence: true, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :terms_and_conditions, acceptance: true
  validates :website, url: true, allow_blank: true

  validates :location_category, presence: true, on: :create, if: :business?
  #validates :business_interests, presence: true, on: :create

  before_validation { self.username.squish! if self.username }

  before_update :mailchimp_user_email_changed, if: -> { email != email_was }
  after_update :mailchimp_user_newsletter_changed, if: -> { saved_change_to_newsletter? }
  after_update :mailchimp_user_update, if: -> { saved_change_to_newsletter? || saved_change_to_email? || saved_change_to_first_name? || saved_change_to_last_name? || saved_change_to_business? || saved_change_to_graetzl_id? }
  after_update :update_user_graetzls, if: -> { saved_change_to_graetzl_id? }
  before_destroy :mailchimp_user_delete
  before_destroy :cancel_subscription

  scope :business, -> { where(business: true) }
  scope :confirmed, -> { where("confirmed_at IS NOT NULL") }

  def beta_user?
    admin? || beta?
  end

  def valid_zuckerl_voucher_for(zuckerl)
    if zuckerl.entire_region?
      free_region_zuckerl.to_i > 0
    else
      free_graetzl_zuckerl.to_i > 0
    end
  end

  def open_region_zuckerl?
    free_region_zuckerl.to_i > 0
  end

  def open_graetzl_zuckerl?
    free_graetzl_zuckerl.to_i > 0
  end

  def open_zuckerl?
    free_region_zuckerl.to_i > 0 || free_graetzl_zuckerl.to_i > 0
  end

  # For better Performance store Subscription State direct in User Model and Update Boolean from Subscriptions
  # def subscribed?
  #  subscription && subscription.active?
  # end

  def subscription
    subscriptions.last
  end

  # Filter for Active Admin User Notification Settings
  def self.user_mail_setting_eq(notification)
    frequency = notification.split("_").first
    type = notification.split("_").last
    type = Notifications.const_get(type)
    case frequency
    when 'weekly', 'daily', 'immediate'
      User.where("#{frequency}_mail_notifications & ? > 0", type.class_bitmask)
    when 'off'
      user = User.where("weekly_mail_notifications & ? <= 0", type.class_bitmask)
      user = user.where("daily_mail_notifications & ? <= 0", type.class_bitmask)
      user.where("immediate_mail_notifications & ? <= 0", type.class_bitmask)
    end
  end

  #scope als filter
  def self.ransackable_scopes(_auth_object = nil)
    [:user_mail_setting_eq]
  end

  # overwrite devise authentication method to allow username OR email
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    if login
      where(conditions.to_h).
        where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).
        first
    else
      where(conditions.to_h).first
    end
  end

  def self.admin_select_collection
    User.all.pluck(:id, :first_name, :last_name, :username).map do |id, first_name, last_name, username|
      ["#{first_name} #{last_name} (#{username})", id]
    end
  end

  def to_s
    full_name
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_with_email
    "#{full_name} (#{email})"
  end

  def full_name_with_user_and_email
    "#{username} | #{full_name} (#{email})"
  end

  def send_confirmation_notification?
    # send confirmation manually from the controller as the after_commit callback clashes with shrine
    false
  end

  def after_confirmation
    UsersMailer.welcome_email(self).deliver_later
    MailchimpUserSubscribeJob.perform_later(self)

    # Default favorite graetzls
    self.favorite_graetzls = self.graetzl.neighbour_graetzls

    # Default groups
    Group.in(region).default_joined.includes(:graetzls).each do |group|
      next if self.groups.include?(group)
      group.group_users.create(user: self) if group.graetzls.include?(self.graetzl)
    end
  end

  def district
    self.graetzl.district
  end

  def followed_graetzl_ids
    favorite_graetzl_ids + [graetzl_id]
  end

  def primary_location
    self.locations.first
  end

  def rooms
    self.room_offers.enabled + self.room_demands.enabled
  end

  def meetings
    self.initiated_meetings + self.attended_meetings
  end

  def recalculate_rating
    ratings = (tool_rentals.pluck(:renter_rating) + owned_tool_rentals.pluck(:owner_rating)).compact
    update(rating: ratings.sum * 1.0 / ratings.size, ratings_count: ratings.size) if ratings.present?
  end

  def mailchimp_member_id
    Digest::MD5.hexdigest(email.downcase)
  end

  def stripe_customer
    if stripe_customer_id.blank?

      # Update Billing Address if already exists
      if self.billing_address.present?
        billing_address_args = {
          name: self.billing_address.full_name,
          address: {
            line1: self.billing_address.company,
            line2: self.billing_address.street,
            postal_code: self.billing_address.zip,
            city: self.billing_address.city,
            country: self.billing_address.country,
          }
        }
      else
        billing_address_args = {}
      end

      args = {
        email: email,
        name: full_name,
      }.merge(billing_address_args)

      stripe_customer = Stripe::Customer.create(args)

      update(stripe_customer_id: stripe_customer.id)

    end
    stripe_customer_id
  end

  def is_favorite_of?(user)
    favorite_users.where(user: user).exists?
  end

  private

  def smart_add_url_protocol
    unless website[/\Ahttp:\/\//] || website[/\Ahttps:\/\//]
      self.website = "https://#{website}"
    end
  end

  def update_user_graetzls
    self.user_graetzls.where(graetzl_id: self.graetzl.id).delete_all
  end

  def mailchimp_user_update
    MailchimpUserSubscribeJob.perform_later(self) if newsletter? && confirmed_at?
  end

  def mailchimp_user_email_changed
    MailchimpUserEmailDeleteJob.perform_later(self.email_was)
  end

  def mailchimp_user_newsletter_changed
    MailchimpUserDeleteJob.perform_later(self) if !newsletter?
  end

  def mailchimp_user_delete
    MailchimpUserDeleteJob.perform_later(self)
  end

  def cancel_subscription
    self.subscriptions.active.last.cancel_now! if self.subscribed?
  end

end
