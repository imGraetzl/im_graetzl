class Meeting < ApplicationRecord
  include Trackable
  include Address

  extend FriendlyId
  friendly_id :name

  belongs_to :graetzl
  has_many :districts, through: :graetzl

  has_many :meeting_additional_dates, dependent: :destroy
  accepts_nested_attributes_for :meeting_additional_dates, allow_destroy: true, reject_if: :all_blank

  belongs_to :poll, optional: true
  belongs_to :location, optional: true
  belongs_to :user, optional: true
  belongs_to :group, optional: true
  has_and_belongs_to_many :event_categories

  has_many :going_tos, dependent: :nullify
  accepts_nested_attributes_for :going_tos, allow_destroy: true
  has_many :users, -> { distinct }, through: :going_tos

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy

  include CoverImageUploader::Attachment(:cover_photo)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  enum state: { active: 0, disabled: 1 }

  scope :entire_region, -> { where(entire_region: true) }
  scope :non_private, -> { where(private: false) }
  scope :online_meeting, -> { where(online_meeting: true) }
  scope :offline_meeting, -> { where(online_meeting: false) }
  scope :crowdfunding, -> { upcoming.joins(:event_categories).where(event_categories: {id: EventCategory.where("title ILIKE :q", q: "%Crowdfunding%").last}) }

  scope :by_currentness, -> {
    active.
    order(Arel.sql('CASE WHEN starts_at_date = current_date THEN 0 WHEN starts_at_date < current_date AND ends_at_date >= current_date THEN 1 WHEN starts_at_date >= current_date THEN 2 WHEN starts_at_date IS NOT NULL THEN 3 ELSE 4 END')).
    order(Arel.sql('(CASE WHEN starts_at_date = current_date THEN meetings.created_at END) DESC, (CASE WHEN starts_at_date < current_date AND ends_at_date > current_date THEN ends_at_date END) ASC, (CASE WHEN starts_at_date >= current_date THEN starts_at_date END) ASC, (CASE WHEN starts_at_date < current_date THEN starts_at_date END) DESC'))
  }

  scope :upcoming, -> { active.
    where("starts_at_date > :today OR ends_at_date > :today", today: Date.yesterday).
    order(:starts_at_date) }

  scope :past, -> { active.
    where("starts_at_date < :today OR ends_at_date < :today", today: Date.yesterday).
    order(:starts_at_date) }
  

  before_validation :smart_add_url_protocol, if: -> { online_url.present? }

  validates_presence_of :name, :description, :starts_at_date, :graetzl
  validates :cover_photo, presence: true, on: :create
  validates :description, presence: true, length: { minimum: 150 }, on: :create
  validate :starts_at_date_cannot_be_in_the_past, on: :create

  before_validation :set_graetzl
  before_create :set_privacy
  before_create :set_entire_region
  after_create :update_location_activity

  def self.visible_to_all
    where(private: false)
  end

  def self.visible_to(user)
    if user && user.group_ids.present?
      where(private: false).or(where(group_id: user.group_ids))
    else
      where(private: false)
    end
  end

  def self.include_for_box
    includes(:going_tos, :user, :meeting_additional_dates, location: :user)
  end

  def to_s
    name
  end

  def past?
    ends_at_date.try(:past?) || (ends_at_date.nil? && starts_at_date.try(:past?))
  end

  def energieteiler?
    false
    #self.event_categories.map(&:title).any? { |cat| cat.include?('Energieteiler') }
  end

  def public?
    !private?
  end

  def display_starts_at_date
    if starts_at_time && ends_at_time
      "#{I18n.localize(starts_at_date, format:'%a, %d. %B %Y')}, #{I18n.localize(starts_at_time, format:'%H:%M')} bis #{I18n.localize(ends_at_time, format:'%H:%M')} Uhr"
    elsif starts_at_time
      "#{I18n.localize(starts_at_date, format:'%a, %d. %B %Y')}, #{I18n.localize(starts_at_time, format:'%H:%M')} Uhr"
    else
      "#{I18n.localize(starts_at_date, format:'%a, %d. %B %Y')}"
    end
  end

  def set_next_date!
    next_meeting = meeting_additional_dates.sort_by(&:starts_at_date).first
    update(
      starts_at_date: next_meeting.starts_at_date,
      starts_at_time: next_meeting.starts_at_time,
      ends_at_time: next_meeting.ends_at_time
    )
    next_meeting.destroy
  end

  def refresh_activity
    if active? && last_activated_at && last_activated_at <= 7.days.ago
      update(last_activated_at: Time.now)
    end
  end

  def attendees
    self.going_tos.where.not(role: :initiator)
  end

  def attending?(user)
    user && going_tos.any?{|gt| gt.user_id == user.id}
  end

  def notification_time_range
    if starts_at_date && ends_at_date
      [starts_at_date - 7.days, ends_at_date]
    elsif starts_at_date
      [starts_at_date - 7.days, starts_at_date]
    else
      [Time.current, nil]
    end
  end

  def notification_sort_date
    starts_at_date
  end

  private

  def starts_at_date_cannot_be_in_the_past
    if starts_at_date && starts_at_date < Date.today
      errors.add(:starts_at, 'kann nicht in der Vergangenheit liegen')
    end
  end

  def smart_add_url_protocol
    unless online_url[/\Ahttp:\/\//] || online_url[/\Ahttps:\/\//]
      self.online_url = "https://#{online_url}"
    end
  end

  def set_graetzl
    self.graetzl ||= user&.graetzl
  end

  def set_privacy
    self.private = true if group && group.private?
  end

  def set_entire_region
    self.entire_region = (entire_region? || energieteiler?) ? true : false
  end

  def update_location_activity
    location.update(last_activity_at: created_at) if location
  end

end
