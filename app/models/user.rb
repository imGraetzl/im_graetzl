class User < ApplicationRecord
  include Address
  include Trackable
  include UserNotifiable

  extend FriendlyId
  friendly_id :username

  attr_accessor :login # virtual attribute to login with username or email

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, :masqueradable

  enum role: { admin: 0, beta: 1, superadmin: 2 }

  include AvatarUploader::Attachment(:avatar)
  include CoverImageUploader::Attachment(:cover_photo)

  belongs_to :graetzl, counter_cache: true, optional: true
  has_many :districts, through: :graetzl
  has_many :user_graetzls
  has_many :favorite_graetzls, through: :user_graetzls, source: :graetzl

  has_many :subscriptions
  has_many :subscription_invoices

  has_many :initiated_meetings, class_name: 'Meeting', dependent: :destroy
  has_many :going_tos, dependent: :destroy
  has_many :meeting_additional_dates, through: :going_tos, source: :meeting
  has_many :attended_meetings, through: :going_tos, source: :meeting

  has_many :comments, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :zuckerls, dependent: :nullify
  has_many :energy_offers, dependent: :destroy
  has_many :energy_demands, dependent: :destroy
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
  has_many :crowd_boost_charges

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

  has_many :poll_users

  has_many :coupon_histories, dependent: :destroy
  has_many :coupons, through: :coupon_histories

  has_one :billing_address, dependent: :destroy
  accepts_nested_attributes_for :billing_address, reject_if: :all_blank

  before_validation :smart_add_url_protocol, if: -> { website.present? }
  before_validation { self.username.squish! if self.username }
  
  # E-Mail-Validierungen
  validates :email, presence: true, if: :email_required?
  validates :email, uniqueness: { scope: :guest, case_sensitive: false }, if: :email_changed?
  validates :email, format: { with: Devise.email_regexp }, if: :email_changed?, allow_blank: true

  # Passwort-Validierungen
  validates :password, presence: true, if: :password_required?
  validates :password, confirmation: true, if: :password_required?
  validates :password, length: { in: Devise.password_length }, allow_blank: true
  
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }, unless: :guest?
  validates :first_name, presence: true, length: { maximum: 50 }, unless: :guest?
  validates :last_name, presence: true, length: { maximum: 50 }, unless: :guest?
  validates :terms_and_conditions, acceptance: true, unless: :guest?
  validates :website, url: true, allow_blank: true, unless: :guest?
  validates :graetzl, presence: true, unless: :guest?
  validates :location_category, presence: true, on: :create, if: :business?, unless: :guest?

  before_update :mailchimp_user_email_changed, if: -> { email != email_was }
  after_update :mailchimp_user_newsletter_changed, if: -> { saved_change_to_newsletter? }
  after_update :mailchimp_user_update, if: -> { saved_change_to_newsletter? || saved_change_to_email? || saved_change_to_first_name? || saved_change_to_last_name? || saved_change_to_business? || saved_change_to_graetzl_id? }
  after_update :update_user_graetzls, if: -> { saved_change_to_graetzl_id? }
  
  before_create :skip_confirmation_for_guests
  before_destroy :mailchimp_user_delete
  before_destroy :cancel_subscription
  before_destroy :convert_to_guest?
  before_destroy :log_user_deletion

  scope :admin, -> { where(role: [:admin, :superadmin]) }
  scope :business, -> { where(business: true) }
  scope :guests, -> { where(guest: true) }
  scope :registered, -> { where(guest: false) }
  scope :confirmed, -> { where.not(confirmed_at: nil).where(guest: false) }

  def admin?
    superadmin? || super
  end

  def admin_or_beta?
    admin? || beta?
  end

  def confirmed_user?
    confirmed_at.present? && !guest?
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

  def has_favorite?(favoritable)
    favorites.any?{|f| f.favoritable_type == favoritable.class.name && f.favoritable_id == favoritable.id}
  end

  def subscription
    subscriptions.last
  end

  def wow?
    if subscribed? && region.wow? && region.wow.any? { |w| w[:user_id] == id }
      region.wow.detect {|w| w[:user_id] == id }
    end
  end

  def show_subscription_hint?
    !subscribed? && created_at < 30.days.ago
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
    conditions[:guest] = false
    if login
      where(conditions.to_h).
        where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).
        first
    else
      where(conditions.to_h).first
    end
  end

  def self.admin_select_collection
    order(created_at: :desc).pluck(:id, :first_name, :last_name, :username).map do |id, first_name, last_name, username|
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
    self.favorite_graetzls = self.graetzl.default_neighbour_graetzls

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
        email: email.strip.downcase,
        name: full_name,
      }.merge(billing_address_args)

      stripe_customer = Stripe::Customer.create(args)

      update(stripe_customer_id: stripe_customer.id)

    end
    stripe_customer_id
  end

  def merge_with_guest_user
    guest_user = User.guests.find_by(email: self.email)
    if guest_user
      transfer_data_from_guest(guest_user)
      guest_user_id = guest_user.id
      guest_user.destroy
      Rails.logger.info "Guest user with ID: #{guest_user_id} was successfully merged and destroyed. New registered User ID: #{self.id}, email: #{self.email}"
    end
  end

  # Devise Overwrites for Guest User Handling

  def self.send_reset_password_instructions(attributes = {})
    # Konvertiere in einen normalen Hash und erlaube nur :email
    attributes = attributes.permit(:email).to_h if attributes.is_a?(ActionController::Parameters)
    attributes[:guest] = false

    recoverable = where(email: attributes[:email], guest: false).first

    if recoverable
      recoverable.send_reset_password_instructions
      recoverable
    else
      # Falls kein regulärer Benutzer mit dieser E-Mail existiert, Devise-Fehlermeldung auslösen
      new(attributes).tap { |user| user.errors.add(:email, :not_found) }
    end
  end

  def self.send_confirmation_instructions(attributes = {})
    # Erlaube nur den :email Parameter und konvertiere in einen regulären Hash
    attributes = attributes.permit(:email).to_h if attributes.is_a?(ActionController::Parameters)
    attributes[:guest] = false

    confirmable = where(email: attributes[:email], guest: false).first

    if confirmable
      #devise already sends the mail via confirmable (deswegen auskommentiert, sonst doppelt)
      #confirmable.send_confirmation_instructions
      confirmable
    else
      # Falls kein regulärer Benutzer mit dieser E-Mail existiert, Devise-Fehlermeldung auslösen
      new(attributes).tap { |user| user.errors.add(:email, :not_found) }
    end
  end

  # Coupon Methoden
  def active_coupons
    coupons
      .where('valid_until > ?', Time.current)
      .where(enabled: true)
      .joins(:coupon_histories)
      .where(coupon_histories: { redeemed_at: nil })
      .distinct
  end

  def redeemed_coupons
    coupon_histories.where.not(redeemed_at: nil).map(&:coupon)
  end

  protected

  # Prüft, ob ein Passwort erforderlich ist
  def password_required?
    !guest? && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end

  # Prüft, ob eine E-Mail erforderlich ist
  def email_required?
    true
  end

  private

  def email_changed?
    will_save_change_to_email?
  end

  def smart_add_url_protocol
    unless website[/\Ahttp:\/\//] || website[/\Ahttps:\/\//]
      self.website = "https://#{website}"
    end
  end

  def update_user_graetzls
    self.user_graetzls.where(graetzl_id: self.graetzl.id).delete_all
  end

  def mailchimp_user_update
    MailchimpUserSubscribeJob.perform_later(self) if newsletter? && confirmed_user?
  end

  def mailchimp_user_email_changed
    MailchimpUserEmailDeleteJob.perform_later(self.email_was) if confirmed_user?
  end

  def mailchimp_user_newsletter_changed
    MailchimpUserEmailDeleteJob.perform_later(self.email) if !newsletter? && confirmed_user?
  end

  def mailchimp_user_delete
    MailchimpUserEmailDeleteJob.perform_later(self.email) if confirmed_user?
  end

  def cancel_subscription
    self.subscriptions.active.last.cancel_now! if subscribed?
  end

  def convert_to_guest?
    return if guest || !crowd_pledges.initialized.exists?
    User.transaction do
      guest_user = User.new(
        guest: true,
        business: false,
        first_name: first_name,
        last_name: last_name,
        email: email,
        address_street: address_street,
        address_zip: address_zip,
        address_city: address_city,
        graetzl_id: graetzl_id,
        region_id: region_id,
        stripe_customer_id: stripe_customer_id,
        created_at: created_at,
        deleted_at: Time.current
      )
      guest_user.save!(validate: false)
      crowd_pledges.initialized.update_all(user_id: guest_user.id)
    end
  end
  
  def log_user_deletion
    Rails.logger.info "[User Deleted]:#{id} (#{email})"
  end

  def skip_confirmation_for_guests
    if guest?
      skip_confirmation!
      skip_confirmation_notification!
      self.confirmed_at = nil
    end
  end

  def transfer_data_from_guest(guest_user)
    # Nur 'origin' übertragen, wenn es beim Gast gesetzt ist
    self.origin = guest_user.origin if guest_user.origin.present?
  
    # 'stripe_customer_id' nur übertragen, wenn es beim Gast gesetzt ist und beim Zielbenutzer noch leer ist
    if guest_user.stripe_customer_id.present? && self.stripe_customer_id.blank?
      self.stripe_customer_id = guest_user.stripe_customer_id
    end
  
    # crowd_pledges-Beziehungen aktualisieren
    guest_user.crowd_pledges.update_all(user_id: self.id)
    guest_user.comments.update_all(user_id: self.id)

    # Speichern ohne Validierung, um sicherzustellen, dass der Transfer erfolgreich ist
    self.save!(validate: false)
  end

end
