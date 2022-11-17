class Zuckerl < ApplicationRecord
  extend FriendlyId
  include AASM
  include ActionView::Helpers

  before_destroy :can_destroy?

  include CoverImageUploader::Attachment(:cover_photo)

  friendly_id :title

  belongs_to :location
  belongs_to :user
  belongs_to :subscription, optional: true
  has_one :graetzl, through: :location

  validates :title, length: { in: 10..80 }
  validates :description, length: { in: 10..160 }
  validates :cover_photo, presence: true
  validates :amount, presence: true, on: :create

  string_enum payment_status: ["free", "authorized", "processing", "debited", "failed"]

  scope :initialized, -> { where.not(aasm_state: :incomplete).where.not(aasm_state: :cancelled) }
  scope :entire_region, -> { where(entire_region: true) }
  scope :graetzl, -> { where(entire_region: false) }
  scope :marked_as_paid, -> { where("debited_at IS NOT NULL") }
  scope :next_month_live, lambda {where("created_at > ? AND created_at < ? AND aasm_state = ? OR aasm_state = ?", Time.now.beginning_of_month, Time.now.end_of_month, 'pending', 'approved')}

  def self.price(region)
    region.zuckerl_graetzl_price * 1.2
  end

  def self.region_price(region)
    region.zuckerl_entire_region_price * 1.2
  end

  aasm do
    state :incomplete, initial: true
    state :pending
    state :approved
    state :cancelled
    state :live
    state :expired

    event :pending do
      transitions from: :incomplete, to: :pending
    end

    event :approve do
      transitions from: [:pending, :live], to: :approved
    end

    event :live do
      transitions from: :approved, to: :live
    end

    event :expire do
      transitions from: :live, to: :expired
    end

    event :cancel do
      transitions to: :cancelled
    end
  end

  def self.in_area(graetzl_ids)
    ids = joins(:location).where("entire_region = 't' OR locations.graetzl_id IN (?)", graetzl_ids).pluck(:id)
    where(id: ids)
  end

  def self.include_for_box
    includes(location: [:location_category])
  end

  def self.random(n)
    order(Arel.sql("RANDOM()")).first(n)
  end

  def self.next_invoice_number
    Zuckerl.where("invoice_number IS NOT NULL").count + 1
  end

  def to_s
    title
  end

  def payment_reference
    "#{model_name.singular}_#{id}_#{created_at.strftime('%y%m')}"
  end

  def basic_price
    entire_region? ? region.zuckerl_entire_region_price : region.zuckerl_graetzl_price
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

  def visibility
    if entire_region?
      "Ganz #{region.name}"
    elsif region.use_districts?
      "#{graetzl.name} und gesamter #{graetzl.district.numeric}. Bezirk"
    else
      graetzl.name
    end
  end

  def runtime
    I18n.localize self.created_at.end_of_month+1.day, format: '%B %Y'
  end

  def zuckerl_invoice
    bucket = Aws::S3::Resource.new.bucket('invoices.imgraetzl.at')
    bucket.object("#{Rails.env}/zuckerls/#{id}-zuckerl.pdf")
  end

  def can_edit?
    ["pending"].include?(self.aasm_state)
  end

  private

  def can_destroy?
    if self.invoice_number?
      throw :abort
    end
  end

end
