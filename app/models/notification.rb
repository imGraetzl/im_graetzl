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
    where(user_id: 10612).next_newsletter
  }

  scope :next_graz, -> {
    where(user_id: 13782).next_newsletter
  }

  scope :next_linz, -> {
    where(user_id: 16539).next_newsletter
  }

  scope :next_kaernten, -> {
    where(user_id: 10613).next_newsletter
  }

  scope :next_muehlviertel, -> {
    where(user_id: 10614).next_newsletter
  }

  def self.generate(subject, child = nil, time_range: [], sort_date: nil, to: {})
    notify_at = time_range.first || Time.current
    notify_before = time_range.last

    if to[:entire_platform].present?
      user_scope = User.confirmed
    elsif to[:region].present?
      user_scope = User.confirmed.in(to[:region])
    elsif to[:graetzl].present? || to[:graetzls].present?
      graetzl_ids = Array(to[:graetzl] || to[:graetzls]).map(&:id)
      user_scope = User.confirmed.where("graetzl_id IN (:g_ids) OR id IN (:u_ids)",
        g_ids: graetzl_ids,
        u_ids: UserGraetzl.where(graetzl_id: graetzl_ids).select(:user_id),
      )
    elsif to[:group].present?
      user_scope = to[:group].users
    elsif to[:user].present? || to[:users].present?
      user_scope = User.confirmed.where(id: Array(to[:user] || to[:users]))
    else
      return
    end

    user_scope.find_in_batches(batch_size: 100) do |users|
      notifications = create_batch(users, subject, child, notify_at, notify_before, sort_date)
      send_immediate_emails(notifications)
    end
  end

  def self.create_batch(users, subject, child, notify_at, notify_before, sort_date)
    notifications_batch = users.map do |user|
      new(
        user: user,
        subject: subject,
        child: child,
        display_on_website: user.enabled_website_notification?(self),
        bitmask: class_bitmask,
        region_id: user.region_id,
        notify_at: notify_at,
        notify_before: notify_before,
        sort_date: sort_date,
      )
    end

    import(notifications_batch, synchronize: notifications_batch)
    notifications_batch
  end

  def self.send_immediate_emails(notifications)
    return if !self.immediate_option_enabled?
    notifications.each do |notification|
      next if notification.notify_at.future?
      next if !notification.user.enabled_mail_notification?(self, :immediate)
      NotificationMailer.send_immediate(notification).deliver_later
    end
  end

  def self.platform_notification?
    self.class_bitmask == 0
  end

  def self.dasherized
    self.name.demodulize.underscore.dasherize
  end

  def self.immediate_option_enabled?
    true
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
