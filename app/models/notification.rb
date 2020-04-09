class Notification < ApplicationRecord
  include Rails.application.routes.url_helpers

  DEFAULT_URL_OPTIONS = Rails.application.config.action_mailer.default_url_options
  DEFAULT_INTERVAL = :off
  DEFAULT_WEBSITE_NOTIFICATION = :off

  belongs_to :user
  belongs_to :activity

  before_create :set_bitmask
  before_create :set_notify_time

  scope :ready_to_be_sent, -> {
    where("notify_at <= CURRENT_DATE").where("notify_before IS NULL OR notify_before >= CURRENT_DATE").
    where(sent: false)
  }

  def self.receive_new_activity(activity)
    CreateNotificationsJob.perform_later activity
  end

  def self.receivers(activity)
    raise NotImplementedError, "receivers method not implemented for #{self.class}"
  end

  def self.description(activity)
    raise NotImplementedError, "description method not implemented for #{self.class}"
  end

  def self.condition(activity)
    true
  end

  def self.notify_owner?
    false
  end

  def self.triggered_by?(activity)
    activity.key.in?(Array(self::TRIGGER_KEY))
  end

  def self.dasherized
    self.name.demodulize.underscore.dasherize
  end

  def self.broadcast(activity)
    triggered_types = ::Notification.subclasses.select{ |klass| klass.triggered_by? activity }
    notified_user_ids = {}
    #sort by bitmask, so that lower order bitmask types are sent first, because
    #higher order bitmask types might not needed to be sent at all, when a user
    #has been already notified via a lower order type.
    triggered_types.sort{|a,b| a::BITMASK <=> b::BITMASK}.each do |klass|
      next if !klass.condition(activity)
      users = klass.receivers(activity)
      users.each do |u|
        #puts '---------BROADCAST NOTIFICATION---------'
        #puts u.id
        next if notified_user_ids[u.id].present?
        next if u == activity.owner && !klass.notify_owner?

        display_on_website = u.enabled_website_notification?(klass) && u != activity.owner
        n = klass.create(activity: activity, user: u, display_on_website: display_on_website)
        #puts '--CREATED NOTIFICATION:'
        #puts n
        send_immediate_email = u.enabled_mail_notification?(klass, :immediate)
        NotificationMailer.send_immediate(n).deliver_later if send_immediate_email
        notified_user_ids[u.id] = true if display_on_website || send_immediate_email
      end
    end
  end

  def to_partial_path
    "notifications/#{type.demodulize.underscore}"
  end

  def mail_template
    type.demodulize.underscore
  end

  def mail_subject
    raise NotImplementedError, "mail_subject method not implemented for #{self.class}"
  end

  private

  def set_bitmask
    self.bitmask ||= self.class::BITMASK
  end

  def set_notify_time
    self.notify_at = Time.current
    self.notify_before = nil
  end
end
