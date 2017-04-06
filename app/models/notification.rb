class Notification < ApplicationRecord
  include Rails.application.routes.url_helpers

  DEFAULT_URL_OPTIONS = Rails.application.config.action_mailer.default_url_options

  belongs_to :user
  belongs_to :activity

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
    activity.key == self::TRIGGER_KEY
  end

  def self.dasherized
    self.name.demodulize.underscore.dasherize
  end

  def self.broadcast(activity)
    triggered_types = ::Notification.subclasses.select{ |klass| klass.triggered_by? activity }
    ids_notified_users = []
    #sort by bitmask, so that lower order bitmask types are sent first, because
    #higher order bitmask types might not needed to be sent at all, when a user
    #has been already notified via a lower order type.
    triggered_types.sort{|a,b| a::BITMASK <=> b::BITMASK}.each do |klass|
      if klass.condition(activity)
        users = klass.receivers(activity)
        users.each do |u|
          next if ids_notified_users.include?(u.id)
          next if u == activity.owner && !klass.notify_owner?
          display_on_website = u.enabled_website_notification?(klass) && u != activity.owner
          n = klass.create(activity: activity, bitmask: klass::BITMASK, display_on_website: display_on_website, user: u)
          if display_on_website
            ids_notified_users << u.id
          elsif !Rails.env.development? && (u.immediate_mail_notifications & klass::BITMASK > 0)
            SendMailNotificationJob.perform_later n
            ids_notified_users << u.id
          end
        end
      end
    end
  end

  def to_partial_path
    "notifications/#{type.demodulize.underscore}"
  end

  def mail_template
    "notification-#{type.demodulize.underscore.dasherize}"
  end

  def basic_mail_vars
    [
      { name: 'graetzl_name', content: activity.trackable.graetzl.name },
      { name: 'graetzl_url', content: graetzl_url(activity.trackable.graetzl, DEFAULT_URL_OPTIONS) },
    ]
  end

  def mail_vars
    raise NotImplementedError, "mail_vars method not implemented for #{self.class}"
  end

  def mail_subject
    raise NotImplementedError, "mail_subject method not implemented for #{self.class}"
  end
end
