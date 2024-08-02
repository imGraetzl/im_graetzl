class RoomBooster < ApplicationRecord
  include ActionView::Helpers

  belongs_to :user
  belongs_to :room_offer
  belongs_to :crowd_boost, optional: true
  has_one :crowd_boost_charge

  validates :amount, presence: true, on: :create

  string_enum status: ["incomplete", "pending", "active", "expired", "storno"]
  string_enum payment_status: ["free", "authorized", "processing", "debited", "failed", "refunded"]

  scope :initialized, -> { where.not(status: :incomplete) }
  scope :active_or_pending, -> { where(status: [:active, :pending]) }

  before_create :set_booster_dates
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

  def next_available_boost_date?(room_booster)
    if RoomBooster.in(room_booster.region).active_or_pending.count < 2
      Date.tomorrow
    else
      newest_boosters = RoomBooster.in(room_booster.region).active_or_pending.sort_by(&:ends_at_date).last(2)
      newest_boosters.first.ends_at_date + 1.day
    end
  end

  def paused?
    false
    #Rails.env.production? && Date.today < ('2024-08-01').to_datetime
  end

  private

  def set_booster_dates
    next_start_date = next_available_boost_date?(self)
    self.starts_at_date = next_start_date
    self.send_at_date = (next_start_date - 1.day).next_occurring(:tuesday)
    self.ends_at_date = next_start_date + 6.days
  end

  def update_crowd_boost_charge
    self.crowd_boost_charge.update(
      payment_status: self.payment_status,
      debited_at: self.debited_at,
    )
  end

end
