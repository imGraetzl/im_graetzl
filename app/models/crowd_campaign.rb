class CrowdCampaign < ApplicationRecord
  include Trackable
  include Address

  extend FriendlyId
  friendly_id :title, :use => :history

  before_destroy :can_destroy?

  def should_generate_new_friendly_id?
    slug.blank? || title_changed? if self.draft?
  end

  belongs_to :user
  belongs_to :graetzl
  has_many :districts, through: :graetzl
  belongs_to :location, optional: true
  belongs_to :room_offer, optional: true

  has_and_belongs_to_many :crowd_categories

  has_many :crowd_rewards
  accepts_nested_attributes_for :crowd_rewards, allow_destroy: true, reject_if: :all_blank

  has_many :crowd_donations
  accepts_nested_attributes_for :crowd_donations, allow_destroy: true, reject_if: :all_blank

  has_many :crowd_pledges
  has_many :crowd_donation_pledges

  has_many :crowd_campaign_posts, dependent: :destroy
  has_many :comments, through: :crowd_campaign_posts
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy

  enum active_state: { enabled: 0, disabled: 1, throttled: 2 }
  enum status: { draft: 0, submit: 1, pending: 2, declined: 3, approved: 4, funding: 5, completed: 6 }
  enum funding_status: { not_funded: 0, goal_1_reached: 1, goal_2_reached: 2 }
  enum billable: { no_bill: 0, bill: 1, donation_bill: 2 }

  include AvatarUploader::Attachment(:avatar)
  include CoverImageUploader::Attachment(:cover_photo)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  before_validation :smart_add_url_protocol_website, if: -> { contact_website.present? }
  before_validation :smart_add_url_protocol_video, if: -> { video.present? }

  # Validation for Campaign Create (& Submit)
  validates_presence_of :title
  # Validation for Campaign Submit
  validates_presence_of :slogan, :crowd_category_ids, :startdate, :enddate, :description, :support_description, :aim_description, :about_description, :funding_1_amount, :funding_1_description, :cover_photo_data, :crowd_reward_ids, :contact_name, :contact_address, :contact_zip, :contact_city, :contact_email, :billable, if: :submit?

  scope :initialized, -> { where.not(status: :declined) }
  scope :scope_throttled, -> { where(active_state: :throttled) }
  scope :none_throttled, -> { where.not(active_state: :throttled) }
  scope :scope_public, -> { where(status: [:funding, :completed]).and(where.not(active_state: :disabled)) }
  scope :successful, -> { where(funding_status: [:goal_1_reached, :goal_2_reached]) }
  scope :guest_newsletter, -> {funding.none_throttled.where(guest_newsletter: true).order(enddate: :asc)}
  
  scope :by_currentness, -> {
    order(Arel.sql('CASE WHEN enddate >= current_date THEN 0 WHEN funding_status != 0 THEN 1 ELSE 2 END')).
    order(Arel.sql('(CASE WHEN enddate >= current_date THEN crowd_campaigns.enddate END) ASC, (CASE WHEN enddate < current_date THEN crowd_campaigns.enddate END) DESC'))
  }

  after_create :set_transaction_fee

  def entire_region?
    !self.throttled?
    #self.service_fee_percentage >= 7 || !self.throttled?
  end

  def closed?
    completed? & (not_funded? || invoice_number.present?)
  end

  def payment_close_date
    enddate + 10.days
  end

  def payment_closed?
    payment_close_date.past?
  end

  def scope_public?
    enabled? && (funding? || completed?)
  end

  def successful?
    goal_1_reached? || goal_2_reached?
  end

  def editable?
    draft? || submit? || pending? || declined?
  end

  def owned_by?(a_user)
    user_id.present? && user_id == a_user&.id
  end

  def actual_newest_post
    crowd_campaign_posts.select{|p| p.created_at > 1.weeks.ago}.last
  end

  def funding_amount_set?
    funding_1_amount?
  end

  def funding_sum
    @cached_funding_sum ||= self.crowd_pledges.initialized.sum(:total_price)
  end

  def funding_count
    @cached_funding_count ||= self.crowd_pledges.initialized.count
  end

  def pledges_and_donations_count
    @cached_pledges_and_donations_count ||= (self.crowd_pledges.initialized.count + self.crowd_donation_pledges.count)
  end

  def effective_funding_sum
    crowd_pledges.debited.sum(:total_price)
  end

  def crowd_pledges_failed_sum
    crowd_pledges.failed.sum(:total_price)
  end

  def transaction_fee_percentage
    if self.service_fee_percentage?
      self.service_fee_percentage
    else
      7
    end
  end

  def service_fee_percentage_owner
    # without stripe
    self.transaction_fee_percentage - 2
  end

  def crowd_pledges_fee
    (effective_funding_sum / 100) * transaction_fee_percentage
  end

  def crowd_pledges_fee_owner
    (effective_funding_sum / 100) * service_fee_percentage_owner
  end

  def crowd_pledges_fee_netto
    (crowd_pledges_fee / 1.20).round(2)
  end

  def crowd_pledges_fee_owner_netto
    (crowd_pledges_fee_owner / 1.20).round(2)
  end

  def crowd_pledges_fee_tax
    (crowd_pledges_fee_netto * 0.2).round(2)
  end

  def crowd_pledges_payout
    effective_funding_sum - crowd_pledges_fee
  end

  def check_funding
    if not_funded? && funding_sum >= funding_1_amount
      update(funding_status: 'goal_1_reached')
      return :goal_1_reached
    elsif funding_2_amount.present? && goal_1_reached? && funding_sum >= funding_2_amount
      update(funding_status: 'goal_2_reached')
      return :goal_2_reached
    end
  end

  def funding_1?
    not_funded?
  end

  def over_funding_1?
    goal_1_reached? && funding_2_amount.nil?
  end

  def funding_2?
    goal_1_reached? && funding_2_amount.present?
  end

  def over_funding_2?
    goal_2_reached?
  end

  def all_steps_finished?
    (1..6).all?{|step| step_finished?(step)}
  end

  def step_finished?(step)
    case step
    when 1
      [title, slogan, description, crowd_category_ids, graetzl_id].all?(&:present?)
    when 2
      [startdate, enddate, support_description, aim_description, about_description].all?(&:present?)
    when 3
      [funding_1_amount, funding_1_description].all?(&:present?)
    when 4
      crowd_rewards.present? && crowd_rewards.all?(&:ready_for_submit?)
    when 5
      [cover_photo_data].all?(&:present?)
    when 6
      [contact_name, contact_address, contact_zip, contact_city, contact_email, billable].all?(&:present?)
    else
      false
    end
  end

  def invoice
    bucket = Aws::S3::Resource.new.bucket('invoices.imgraetzl.at')
    bucket.object("#{Rails.env}/crowdfunding/#{id}-crowd_campaign.pdf")
  end

  def self.next_invoice_number
    where("invoice_number IS NOT NULL").count + 1
  end

  def remaining_days
    ((self.enddate - Date.today) + 1).to_i if self.enddate
  end

  def runtime
    "#{I18n.localize(self.startdate, format:'%d. %b %Y') if self.startdate} bis #{I18n.localize(self.enddate, format:'%d. %b %Y') if self.enddate}"
  end

  def notification_time_range
    [startdate, enddate]
  end

  def to_s
    title
  end

  def full_name
    contact_name
  end

  def email
    contact_email
  end

  def district
    self.graetzl.district
  end

  def subscribed?
    user&.subscribed?
  end

  private

  def smart_add_url_protocol_website
    unless contact_website[/\Ahttp:\/\//] || contact_website[/\Ahttps:\/\//]
      self.contact_website = "https://#{contact_website}"
    end
  end

  def smart_add_url_protocol_video
    unless video[/\Ahttp:\/\//] || video[/\Ahttps:\/\//]
      self.video = "https://#{video}"
    end
  end

  def can_destroy?
    if !(self.draft? || self.declined?)
      throw :abort
    end
  end

  def set_transaction_fee
    self.service_fee_percentage = self.transaction_fee_percentage
    self.save
  end

end
