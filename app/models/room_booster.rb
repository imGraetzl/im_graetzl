class RoomBooster < ApplicationRecord
  include ActionView::Helpers

  belongs_to :user
  belongs_to :room_offer
  validates :amount, presence: true, on: :create

  string_enum status: ["incomplete", "pending", "active", "expired", "storno"]
  string_enum payment_status: ["authorized", "processing", "debited", "failed", "refunded"]

  scope :initialized, -> { where.not(status: :incomplete) }
  scope :upcoming, -> { where("send_at_date > :today", today: Date.today)}

  after_update :update_room_offer, if: -> { saved_change_to_status? }
  before_create :set_send_at_date

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
    "#{I18n.localize(self.created_at, format:'%d.%m.%Y') if self.created_at} - #{I18n.localize(self.created_at + 7.days, format:'%d.%m.%Y') if self.created_at}"
  end

  def update_room_offer
    if room_offer && active?
      room_offer.update_attribute(:boosted, true)
    elsif room_offer
      room_offer.update_attribute(:boosted, false)
    end
  end

  private

  def set_send_at_date
    self.send_at_date = Date.today.next_occurring(:tuesday)
  end

end
