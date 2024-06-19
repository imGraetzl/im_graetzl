class Zuckerl < ApplicationRecord
  extend FriendlyId
  include AASM
  include ActionView::Helpers

  before_destroy :can_destroy?

  include CoverImageUploader::Attachment(:cover_photo)

  friendly_id :title

  belongs_to :location, optional: true
  belongs_to :user, optional: true
  belongs_to :subscription, optional: true
  has_one :graetzl, through: :location
  belongs_to :crowd_boost, optional: true
  has_one :crowd_boost_charge

  before_validation :smart_add_url_protocol, if: -> { link.present? }

  validates_presence_of :title, :description, :cover_photo, :starts_at, :ends_at
  validates :amount, presence: true, on: :create

  string_enum payment_status: ["free", "authorized", "processing", "debited", "failed", "refunded"]

  scope :initialized, -> { where.not(aasm_state: [:incomplete, :cancelled, :storno]) }
  scope :entire_region, -> { where(entire_region: true) }
  scope :graetzl, -> { where(entire_region: false) }

  after_update :update_crowd_boost_charge, if: -> { crowd_boost_charge.present? && saved_change_to_payment_status? }

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
    state :live
    state :expired
    state :cancelled
    state :storno

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

    event :storno do
      transitions to: :storno
    end
  end

  def self.in_area(graetzl_ids)
    ids = joins(:location).where("zuckerls.entire_region = 't' OR locations.graetzl_id IN (?)", graetzl_ids).pluck(:id)
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
    "#{I18n.localize starts_at, format: '%d. %b'} – #{I18n.localize ends_at, format: '%d. %b, %Y'}"
  end

  def zuckerl_invoice
    bucket = Aws::S3::Resource.new.bucket('invoices.imgraetzl.at')
    bucket.object("#{Rails.env}/zuckerls/#{id}-zuckerl.pdf")
  end

  def can_edit?
    ["pending"].include?(self.aasm_state)
  end

  private

  def smart_add_url_protocol
    unless link[/\Ahttp:\/\//] || link[/\Ahttps:\/\//]
      self.link = "https://#{link}"
    end
  end

  def can_destroy?
    if self.invoice_number?
      throw :abort
    end
  end

  def update_crowd_boost_charge
    self.crowd_boost_charge.update(
      payment_status: self.payment_status,
      debited_at: self.debited_at,
    )
  end

end
