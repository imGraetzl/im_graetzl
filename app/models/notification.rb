class Notification < ApplicationRecord
  class_attribute :class_bitmask

  DEFAULT_INTERVAL = :off
  DEFAULT_WEBSITE_NOTIFICATION = :off

  belongs_to :user
  belongs_to :subject, polymorphic: true
  belongs_to :child, optional: true, polymorphic: true

  # notify_at >= CURRENT_DATE for Local Testing Preview
  scope :ready_to_be_sent, -> {
    where("notify_at <= CURRENT_DATE").where("notify_before IS NULL OR notify_before >= CURRENT_DATE").
    where(sent: false)
  }

  scope :by_currentness, -> {
    order(Arel.sql('(CASE WHEN sort_date >= current_date THEN sort_date END) ASC'))
  }

  ## Next Newsletter Notifications for Active Admin
  next_tuesday = Date.today.next_occurring(:tuesday)

  scope :next_newsletter, -> {
    where("notify_at <= ?", next_tuesday).
    where("notify_before IS NULL OR notify_before >= ?", next_tuesday).
    where(sent: false)
  }

  scope :next_wien, -> {
    User.find_by_id(10612)&.notifications&.next_newsletter
  }

  scope :next_graz, -> {
    User.find_by_id(13782)&.notifications&.next_newsletter
  }

  scope :next_linz, -> {
    User.find_by_id(16539)&.notifications&.next_newsletter
  }

  scope :next_kaernten, -> {
    User.find_by_id(10613)&.notifications&.next_newsletter
  }

  scope :next_muehlviertel, -> {
    User.find_by_id(10614)&.notifications&.next_newsletter
  }

  def self.generate(subject, child = nil, to:, time_range: [], sort_date: nil)
    user_ids = Array(to)
    return if user_ids.empty?
    # TODO: also return if time_range.first > X ? (1month in zukunft ?!)
    # dann rausnehmen aus action prozessor und dort kann evtl die activity erstellt werden?
    # oder auch bei activity erstellung das gleiche rein?

    notifications = User.where(id: user_ids).find_each.map do |user|
      new(
        user: user,
        subject: subject,
        child: child,
        display_on_website: user.enabled_website_notification?(self),
        bitmask: class_bitmask,
        region_id: user.region_id,
        notify_at: time_range.first || Time.current,
        notify_before: time_range.last,
        sort_date: sort_date,
      )
    end

    import(notifications, synchronize: notifications)

    notifications.each do |notification|
      # Dont send if notify_at is in future
      if notification.notify_at <= Date.current && notification.user.enabled_mail_notification?(self, :immediate)
        NotificationMailer.send_immediate(notification).deliver_later
      end
    end
  
  end

  def self.platform_notification?
    self.class_bitmask == 0
  end

  def self.dasherized
    self.name.demodulize.underscore.dasherize
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

end
