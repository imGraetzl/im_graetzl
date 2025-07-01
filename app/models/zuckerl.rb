class Zuckerl < ApplicationRecord
  #extend FriendlyId
  include AASM
  include ActionView::Helpers

  before_destroy :can_destroy?

  include CoverImageUploader::Attachment(:cover_photo)

  #friendly_id :title

  has_many :zuckerl_graetzls, dependent: :destroy
  has_many :graetzls, through: :zuckerl_graetzls
  has_many :districts, -> { distinct }, through: :graetzls
  belongs_to :location, optional: true
  belongs_to :user, optional: true
  belongs_to :subscription, optional: true
  belongs_to :crowd_boost, optional: true
  has_one :crowd_boost_charge

  before_validation :smart_add_url_protocol, if: -> { link.present? }

  validates_presence_of :title, :description, :cover_photo, :starts_at, :ends_at
  validates :amount, presence: true, on: :create

  enum payment_status: { free: "free", authorized: "authorized", processing: "processing", debited: "debited", failed: "failed", refunded: "refunded" }

  scope :redeemed, -> { free.where.not(aasm_state: [:storno]) }
  scope :initialized, -> { where.not(aasm_state: [:incomplete, :cancelled, :storno]) }
  scope :entire_region, -> { where(entire_region: true) }
  scope :graetzl, -> { where(entire_region: false) }

  after_update :update_crowd_boost_charge, if: -> { crowd_boost_charge.present? && saved_change_to_payment_status? }

  def self.price(region)
    region.zuckerl_graetzl_price * 1.2
  end

  def self.region_price(region)
    region.zuckerl_region_price * 1.2
  end

  def self.old_price(region)
    region.zuckerl_graetzl_old_price ? region.zuckerl_graetzl_old_price * 1.2 : nil
  end

  def self.region_old_price(region)
    region.zuckerl_region_old_price ? region.zuckerl_region_old_price * 1.2 : nil
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
    # Subquery: Holt nur die IDs der passenden Zuckerls
    subquery = select('zuckerls.id')
                 .left_joins(:graetzls)
                 .where("zuckerls.entire_region = TRUE OR graetzls.id IN (?)", graetzl_ids)
                 .distinct
  
    # Äußere Query: Zufällige Sortierung nur in der äußeren Query
    Zuckerl.where(id: subquery)
  end
  

  def self.include_for_box
    includes(location: [:location_category])
  end

  def self.random(n)
    reorder(Arel.sql("RANDOM()")).first(n)
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
    entire_region? ? region.zuckerl_region_price : region.zuckerl_graetzl_price
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
    elsif region.use_districts? && graetzls.present?
      District.find(saved_main_district).zip_name
    elsif graetzls.present?
      graetzls.first.name
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

  def location?
    location.present?
  end

  def default_graetzl
    location&.graetzl || user.graetzl
  end

  def saved_main_district
    return "entire_region" if entire_region?
    graetzls
      .joins(:districts)
      .group('districts.id')
      .order('COUNT(districts.id) DESC')
      .limit(1)
      .pluck('districts.id')
      .first
  end

  def saved_graetzl
    return "entire_region" if entire_region?
    graetzls
      .limit(1)
      .pluck('id')
      .first
  end

  def saved_or_default_district(params_district_id = nil)
    (params_district_id.to_i if params_district_id.present?) || saved_main_district || default_graetzl&.district&.id
  end

  def saved_or_default_graetzl(params_graetzl_id = nil)
    (params_graetzl_id.to_i if params_graetzl_id.present?) || saved_graetzl || default_graetzl&.id
  end
  

  private

  def smart_add_url_protocol
    unless link[/\Ahttp:\/\//] || link[/\Ahttps:\/\//]
      self.link = "https://#{link}"
    end
  end

  def can_destroy?
    if self.invoice_number? || self.aasm_state != "incomplete"
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
