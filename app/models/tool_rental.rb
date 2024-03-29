class ToolRental < ApplicationRecord
  include Trackable
  belongs_to :user
  belongs_to :tool_offer

  has_one :user_message_thread

  enum rental_status: { incomplete: 0, pending: 1, canceled: 2, rejected: 3, approved: 4, return_pending: 5, return_confirmed: 6, expired: 7, paid_out: 8, storno: 9 }
  string_enum payment_status: ["authorized", "processing", "debited", "failed", "refunded"]

  scope :initialized, -> { where.not(rental_status: :incomplete) }

  before_create :set_region

  def self.next_invoice_number
    where("invoice_number IS NOT NULL").count + 1
  end

  def owner
    tool_offer.user if tool_offer
  end

  def renter
    user
  end

  def renter_billing_address
    {
      first_name: renter_name && renter_name.split(' ', 2).first,
      last_name: renter_name && renter_name.split(' ', 2).last,
      company: renter_company,
      street: renter_address,
      zip: renter_zip,
      city: renter_city,
    }
  end

  def days
    (rent_to - rent_from).to_i + 1
  end

  def calculate_price
    self.daily_price = tool_offer.price_per_day
    self.basic_price = (daily_price * days).round(2)
    if days >= 7
      self.discount = (basic_price * tool_offer.weekly_discount.to_i / 100).round(2)
    elsif days >= 2
      self.discount = (basic_price * tool_offer.two_day_discount.to_i / 100).round(2)
    else
      self.discount = 0
    end
    self.service_fee = ((basic_price - discount) * 0.065).round(2)
    #self.insurance_fee = ((basic_price - discount) * 0.08).round(2)
    self.insurance_fee = 0
    self.tax = (service_fee * 0.20).round(2)
  end

  def total_price
    basic_price - discount + total_fee
  end

  def total_fee
    service_fee + tax + insurance_fee
  end

  def owner_payout_amount
    basic_price - discount - service_fee - tax
  end

  def invoice_ready?
    processing? || debited?
  end

  def payout_ready?
    return_confirmed? && debited? && rent_to < Date.today
  end

  def owner_invoice
    bucket = Aws::S3::Resource.new.bucket('invoices.imgraetzl.at')
    bucket.object("#{Rails.env}/tool_rentals/#{id}-owner.pdf")
  end

  def renter_invoice
    bucket = Aws::S3::Resource.new.bucket('invoices.imgraetzl.at')
    bucket.object("#{Rails.env}/tool_rentals/#{id}-renter.pdf")
  end

  private

  def set_region
    self.region_id = tool_offer.region_id
  end

end
