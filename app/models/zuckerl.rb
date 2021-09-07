class Zuckerl < ApplicationRecord
  extend FriendlyId
  include AASM
  include ActionView::Helpers

  before_destroy :can_destroy?

  include CoverImageUploader::Attachment(:cover_photo)

  friendly_id :title
  attr_accessor :active_admin_requested_event

  belongs_to :location
  belongs_to :user
  has_one :graetzl, through: :location

  after_commit :send_booking_confirmation, on: :create, if: proc {|zuckerl| zuckerl.pending?}

  validates :title, length: { in: 4..80 }

  scope :entire_region, -> { where(entire_region: true) }
  scope :marked_as_paid, -> { where("paid_at IS NOT NULL") }
  scope :this_month_live, lambda {where("created_at > ? AND created_at < ?", Time.now.beginning_of_month - 1.month, Time.now.end_of_month - 1.month).or(Zuckerl.live)}
  scope :next_month_live, lambda {where("created_at > ? AND created_at < ? AND aasm_state != ? AND aasm_state != ?", Time.now.beginning_of_month, Time.now.end_of_month, 'live', 'cancelled')}


  def self.price(region)
    region.zuckerl_graetzl_price * 1.2
  end

  def self.region_price(region)
    region.zuckerl_entire_region_price * 1.2
  end

  aasm do
    state :pending, initial: true
    state :draft
    state :paid
    state :live
    state :cancelled
    state :expired

    event :mark_as_paid, guard: lambda { paid_at.blank? }, after: :send_invoice do
      transitions from: :pending, to: :paid
      transitions from: :live, to: :live
    end

    event :put_live, after: :send_live_information do
      transitions from: [:pending, :draft, :paid], to: :live
    end

    event :expire do
      transitions from: :live, to: :expired
    end

    event :cancel do
      transitions to: :cancelled
    end
  end

  def self.for_area(area)
    if area.is_a?(Graetzl)
      graetzl_ids = area.region.use_districts? ? area.district.graetzl_ids : [area.id]
    elsif area.is_a?(District)
      graetzl_ids = area.graetzl_ids
    end
    Zuckerl.live.joins(:location).where("entire_region = 't' OR locations.graetzl_id IN (?)", graetzl_ids)
  end

  def self.include_for_box
    includes(location: [:location_category])
  end

  def self.next_invoice_number
    Zuckerl.where("invoice_number IS NOT NULL").count + 1
  end

  def to_s
    title
  end

  def url
    unless self.link.nil?
      self.link
    else
      Rails.application.routes.url_helpers.graetzl_location_path(graetzl, location, anchor: dom_id(self))
    end
  end

  def payment_reference
    "#{model_name.singular}_#{id}_#{created_at.strftime('%y%m')}"
  end

  def basic_price
    entire_region? ? Zuckerl.region_price(region) / 1.2 : Zuckerl.price(region) / 1.2
  end

  def tax
    (basic_price * 0.20)
  end

  def total_price
    basic_price + tax
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

  def visibility
    if entire_region?
      "Ganz #{region.name}"
    elsif region.use_districts?
      "#{graetzl.name} und gesamter #{graetzl.district.numeric}. Bezirk"
    else
      graetzl.name
    end
  end

  def zuckerl_invoice
    bucket = Aws::S3::Resource.new.bucket('invoices.imgraetzl.at')
    bucket.object("#{Rails.env}/zuckerls/#{id}-zuckerl.pdf")
  end

  private

  def can_destroy?
    if self.invoice_number?
      throw :abort
    end
  end

  def send_booking_confirmation
    AdminMailer.new_zuckerl(self).deliver_later
    ZuckerlMailer.booking_confirmation(self).deliver_later
  end

  def send_live_information
    ZuckerlMailer.live_information(self).deliver_later
  end

  def generate_invoice(zuckerl)
    zuckerl_invoice = ZuckerlInvoice.new.invoice(zuckerl)
    zuckerl.zuckerl_invoice.put(body: zuckerl_invoice)
  end

  def send_invoice
    update(paid_at: Time.now)
    invoice_number = "#{Date.current.year}_Zuckerl-#{self.id}_Nr-#{Zuckerl.next_invoice_number}"
    update(invoice_number: invoice_number)
    generate_invoice(self)
    ZuckerlMailer.invoice(self).deliver_later(wait: 1.minute)
  end

end
