class RoomBooster < ApplicationRecord
  include ActionView::Helpers

  MAX_WEEKLY_BOOSTERS = 2

  belongs_to :user
  belongs_to :room_offer
  belongs_to :crowd_boost, optional: true
  has_one :crowd_boost_charge

  validates :amount, presence: true, on: :create

  enum :status, { incomplete: "incomplete", pending: "pending", active: "active", expired: "expired", storno: "storno", deleted: "deleted" }
  enum :payment_status, { free: "free", authorized: "authorized", processing: "processing", debited: "debited", failed: "failed", refunded: "refunded" }

  scope :initialized, -> { where.not(status: :incomplete) }
  scope :active_or_pending, -> { where(status: [:active, :pending]) }

  before_validation :set_booster_dates, on: :create
  before_validation :sync_booster_dates, if: -> { will_save_change_to_starts_at_date? }
  after_update :update_room_offer, if: -> { saved_change_to_status? }
  after_update :update_crowd_boost_charge, if: -> { crowd_boost_charge.present? && saved_change_to_payment_status? }

  def self.next_invoice_number
    where("invoice_number IS NOT NULL").count + 1
  end

  def self.price(region)
    region.room_booster_price * 1.2
  end

  def basic_price
    region.room_booster_price
  end

  def tax
    basic_price * 0.20
  end

  def total_price
    basic_price + tax
  end

  def amount_with_currency
    number_to_currency(amount)
  end

  def basic_price_with_currency
    number_to_currency(basic_price / 100)
  end

  def tax_with_currency
    number_to_currency(tax / 100)
  end

  def total_price_with_currency
    number_to_currency((basic_price + tax) / 100)
  end

  def invoice
    bucket = Aws::S3::Resource.new.bucket('invoices.imgraetzl.at')
    bucket.object("#{Rails.env}/room_boosters/#{id}-room-booster.pdf")
  end

  def notification_time_range
    [send_at_date, nil]
  end

  def notification_sort_date
    send_at_date
  end

  def runtime
    "#{I18n.localize(self.starts_at_date, format:'%d.%m.%Y')} - #{I18n.localize(self.ends_at_date, format:'%d.%m.%Y')}"
  end

  def update_room_offer
    if room_offer && active?
      room_offer.update_attribute(:boosted, true)
    elsif room_offer && (expired? || storno?)
      room_offer.update_attribute(:boosted, false)
    end
  end

  def self.next_available_start_date(region, start_date: Date.tomorrow)
    base_date = start_date.to_date
    ranges = RoomBooster.in(region).active_or_pending.where.not(starts_at_date: nil, ends_at_date: nil).pluck(:starts_at_date, :ends_at_date)

    return base_date if ranges.empty?

    # Build per-day occupancy from existing boosters, starting at base_date.
    last_end_date = [ranges.map(&:last).compact.max, base_date].max
    daily_counts = Hash.new(0)

    ranges.each do |range_start, range_end|
      next if range_start.nil? || range_end.nil? || range_end < base_date

      start_day = [range_start, base_date].max
      (start_day..range_end).each { |date| daily_counts[date] += 1 }
    end

    candidate = base_date
    last_candidate = last_end_date + 1.day

    # Slide a 7-day window; the first with no day at capacity (2) is valid.
    while candidate <= last_candidate
      window_full = (candidate..candidate + 6.days).any? { |date| daily_counts[date] >= MAX_WEEKLY_BOOSTERS }
      return candidate unless window_full

      candidate += 1.day
    end

    last_end_date + 1.day
  end

  def next_available_boost_date?(room_booster)
    self.class.next_available_start_date(room_booster.region, start_date: Date.tomorrow)
  end

  def paused?
    false
    #Rails.env.production? && Date.today < ('2024-08-01').to_datetime
  end

  private

  def set_booster_dates
    return if starts_at_date.present?

    self.starts_at_date = next_available_boost_date?(self)
  end

  def sync_booster_dates
    return if starts_at_date.blank?

    self.send_at_date = (starts_at_date - 1.day).next_occurring(:tuesday)
    self.ends_at_date = starts_at_date + 6.days
  end

  def update_crowd_boost_charge
    self.crowd_boost_charge.update(
      payment_status: self.payment_status,
      debited_at: self.debited_at,
    )
  end

end
