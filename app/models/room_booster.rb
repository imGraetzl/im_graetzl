class RoomBooster < ApplicationRecord
  include ActionView::Helpers

  belongs_to :user
  belongs_to :room_offer
  validates :amount, presence: true, on: :create

  string_enum status: ["incomplete", "pending", "active", "expired", "storno"]
  string_enum payment_status: ["free", "authorized", "processing", "debited", "failed", "refunded"]

  scope :initialized, -> { where.not(status: :incomplete) }
  scope :upcoming, -> { active.where("send_at_date > :today", today: Date.today)}

  before_create :set_booster_dates
  after_update :update_room_offer, if: -> { saved_change_to_status? }

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

  def boost_available?(room_booster)
    RoomBooster.in(room_booster.region).active.count < 2
  end

  def next_available_boost_date?(room_booster)
    if boost_available?(room_booster)
      Date.today
    elsif RoomBooster.in(room_booster.region).pending.count < 2
      RoomBooster.in(room_booster.region).active.sort_by(&:ends_at_date).first.ends_at_date + 1.day
    else
      RoomBooster.in(room_booster.region).pending.sort_by(&:ends_at_date).first.ends_at_date + 1.day
    end
  end

  private

  def set_booster_dates
    next_start_date = next_available_boost_date?(self)
    self.starts_at_date = next_start_date
    self.send_at_date = next_start_date.next_occurring(:tuesday)
    self.ends_at_date = next_start_date + 7.days
  end

end
