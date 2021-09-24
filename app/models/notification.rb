class Notification < ApplicationRecord
  class_attribute :class_bitmask

  DEFAULT_INTERVAL = :off
  DEFAULT_WEBSITE_NOTIFICATION = :off

  belongs_to :user
  belongs_to :subject, polymorphic: true
  belongs_to :child, optional: true, polymorphic: true

  belongs_to :activity, optional: true # Remove after deployment

  scope :ready_to_be_sent, -> {
    where("notify_at <= CURRENT_DATE").where("notify_before IS NULL OR notify_before >= CURRENT_DATE").
    where(sent: false)
  }

  def self.generate(subject, child = nil, to:, time_range: [])
    return if to.empty?

    notifications = User.where(id: to).find_each.map do |user|
      new(
        user: user,
        subject: subject,
        child: child,
        display_on_website: user.enabled_website_notification?(self),
        bitmask: class_bitmask,
        region_id: subject.region_id,
        notify_at: time_range.first || Time.current,
        notify_before: time_range.last,
      )
    end

    import(notifications, synchronize: notifications)

    notifications.each do |notification|
      if notification.user.enabled_mail_notification?(self, :immediate)
        NotificationMailer.send_immediate(notification).deliver_later
      end
    end
  end

  def self.platform_notification?
    self.class_bitmask.nil?
  end

  def self.dasherized
    self.name.demodulize.underscore.dasherize
  end

  def mail_template
    type.demodulize.underscore
  end

  def mail_subject
    raise NotImplementedError, "mail_subject method not implemented for #{self.class}"
  end

end