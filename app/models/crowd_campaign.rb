class CrowdCampaign < ApplicationRecord
  DEFAULT_SERVICE_FEE_PERCENTAGE = 9

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
  belongs_to :crowd_boost_slot, optional: true
  has_one :crowd_boost, through: :crowd_boost_slot
  has_and_belongs_to_many :crowd_categories

  has_many :crowd_rewards
  accepts_nested_attributes_for :crowd_rewards, allow_destroy: true, reject_if: :all_blank

  has_many :crowd_donations
  accepts_nested_attributes_for :crowd_donations, allow_destroy: true, reject_if: :all_blank

  has_many :crowd_pledges
  has_many :crowd_donation_pledges
  has_many :crowd_boost_pledges

  has_many :supporters, through: :crowd_pledges, source: :user

  has_many :crowd_campaign_posts, dependent: :destroy
  has_many :comments, through: :crowd_campaign_posts
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy
  
  enum :boost_status, { boost_declined: "boost_declined", boost_waitlist: "boost_waitlist", boost_approved: "boost_approved", boost_authorized: "boost_authorized", boost_debited: "boost_debited", boost_cancelled: "boost_cancelled" }
  enum :transfer_status, { payout_waiting: "payout_waiting", payout_ready: "payout_ready", payout_processing: "payout_processing", payout_completed: "payout_completed", payout_failed: "payout_failed" }
  enum :visibility_status, { graetzl: "graetzl", region: "region", platform: "platform" }
  enum :newsletter_status, { none: "none", graetzl: "graetzl", region: "region", platform: "platform" }, prefix: :newsletter
  enum :active_state, { enabled: 0, disabled: 1, hidden: 2 }
  enum :status, { draft: 0, submit: 1, pending: 2, declined: 3, approved: 4, funding: 5, completed: 6, re_draft: 7 }
  enum :funding_status, { not_funded: 0, goal_1_reached: 1, goal_2_reached: 2 }
  enum :billable, { no_bill: 0, bill: 1, donation_bill: 2 }
  enum :importance, { low: 0, medium: 1, high: 2 }, prefix: :importance

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
  scope :boost_initialized, -> { where(boost_status: [:boost_authorized, :boost_debited]) }
  scope :scope_public, -> { where(status: [:funding, :completed]).and(where.not(active_state: [:disabled, :hidden])) }
  scope :region_or_platform, -> { where(visibility_status: [:region, :platform]) }
  scope :successful, -> { where(funding_status: [:goal_1_reached, :goal_2_reached]) }
  scope :payout, -> { where(transfer_status: [:payout_waiting, :payout_ready, :payout_processing, :payout_failed]) }
  scope :guest_newsletter, -> { funding.where(guest_newsletter: true) }
  scope :ending_newsletter, -> { funding.where(ending_newsletter: true) }
  scope :incomplete_newsletter, -> { funding.where(incomplete_newsletter: true) }
  scope :by_currentness, -> {
    order(Arel.sql('CASE WHEN enddate >= current_date THEN 0 WHEN funding_status != 0 THEN 1 ELSE 2 END')).
    order(Arel.sql('(CASE WHEN enddate >= current_date THEN crowd_campaigns.last_activity_at END) DESC, 
                    (CASE WHEN enddate >= current_date THEN crowd_campaigns.enddate END) ASC, 
                    (CASE WHEN enddate < current_date THEN crowd_campaigns.enddate END) DESC'))
  }

  after_create :set_transaction_fee
  after_commit :send_draft_mail, on: :create
  after_update :set_visibility_and_newsletter, if: -> { saved_change_to_status? && approved? }

  def entire_graetzl?
    visibility_status == "graetzl"
  end

  def entire_region?
    visibility_status == "region"
  end

  def entire_platform?
    visibility_status == "platform"
  end

  def closed?
    completed? & (not_funded? || invoice_number.present?)
  end

  def payment_close_date
    enddate + 12.days
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
    draft? || re_draft? || submit? || pending? || declined?
  end

  def boosted?
    boost_authorized? || boost_debited?
  end

  def boostable?
    (boost_waitlist? && boost_waitlisted_at.present?) || boost_approved? || boost_authorized? || boost_debited? || boost_cancelled?
  end

  def owned_by?(a_user)
    user_id.present? && user_id == a_user&.id
  end

  def actual_newest_post
    @actual_newest_post ||= crowd_campaign_posts
      .where("created_at > ?", 1.week.ago)
      .order(created_at: :desc)
      .limit(1)
      .first
  end

  def funding_amount_set?
    funding_1_amount?
  end

  def funding_sum
    if completed? && finalized_funding_sum_available?
      crowd_pledges_finalized_sum + (boosted? ? crowd_boost_pledges_finalized_sum : 0)
    else
      @funding_sum ||= crowd_pledges_sum + (boosted? ? crowd_boost_pledges_sum : 0)
    end
  end

  def finalized_funding_sum_available?
    crowd_pledges_finalized_sum.present? && (!boosted? || crowd_boost_pledges_finalized_sum.present?)
  end

  def funding_sum_uncached
    crowd_pledges.initialized.sum(:total_price) + crowd_boost_pledges.initialized.sum(:amount)
  end

  def crowd_pledges_sum
    @crowd_pledges_sum ||= crowd_pledges.initialized.sum(:total_price)
  end

  def crowd_boost_pledges_sum
    @crowd_boost_pledges_sum ||= crowd_boost_pledges.initialized.sum(:amount)
  end

  def funding_count
    @funding_count ||= crowd_pledges.initialized.count
  end

  def pledges_and_donations_count
    if completed? && pledges_and_donations_finalized_count.present?
      pledges_and_donations_finalized_count
    else
      @pledges_and_donations_count ||= (
        crowd_pledges.initialized.count + crowd_donation_pledges_count
      )
    end
  end

  def effective_funding_sum
    crowd_pledges.debited.sum(:total_price) + crowd_boost_pledges.debited.sum(:amount)
  end

  def crowd_pledges_failed_sum
    crowd_pledges.failed.sum(:total_price)
  end

  def crowd_pledges_processing_sum
    crowd_pledges.processing.sum(:total_price)
  end

  def crowd_pledges_refunded_sum
    crowd_pledges.refunded.sum(:total_price)
  end

  def transaction_fee_percentage
    service_fee_percentage? ? service_fee_percentage : DEFAULT_SERVICE_FEE_PERCENTAGE
  end

  def stripe_fee_percentage
    # average percentage
    2
  end

  def stripe_fee_percentage_calculated
    # calculated real stripe fee percentage
    pledges = crowd_pledges.debited.where.not(stripe_fee: nil)
    return 0.0 if pledges.empty?
    total_price = pledges.sum(:total_price)
    return 0.0 if total_price.zero?
    stripe_fee = pledges.sum(:stripe_fee)
    ((stripe_fee / total_price) * 100).round(2)
  end

  def funding_percentage
    funding_sum / (funding_1_amount / 100)
  end

  def crowd_pledges_fee
    (effective_funding_sum / 100) * transaction_fee_percentage
  end

  def crowd_pledges_fee_netto
    (crowd_pledges_fee / 1.20).round(2)
  end

  def crowd_pledges_fee_tax
    (crowd_pledges_fee_netto * 0.2).round(2)
  end

  def crowd_boost_pledges_netto
    if self.vat_id?
      (crowd_boost_pledges_sum / 1.20).round(2)
    else
      crowd_boost_pledges_sum
    end
  end

  def crowd_boost_pledges_tax
    if self.vat_id?
      (crowd_boost_pledges_netto * 0.2).round(2) if self.vat_id?
    else
      0
    end
  end

  def stripe_fee
    (effective_funding_sum / 100) * stripe_fee_percentage
  end

  def platform_fee_netto
    crowd_pledges_fee_netto - stripe_fee
  end

  def crowd_pledges_payout
    effective_funding_sum - crowd_pledges_fee
  end

  def check_funding
    if funding_2_amount.present? && (not_funded? || goal_1_reached?) && funding_sum_uncached >= funding_2_amount
      update(
        funding_status: 'goal_2_reached',
        goal_2_reached_at: goal_2_reached_at || Time.current
      )
      return :goal_2_reached
    elsif not_funded? && funding_sum_uncached >= funding_1_amount
      update(
        funding_status: 'goal_1_reached',
        goal_1_reached_at: goal_1_reached_at || Time.current
      )
      return :goal_1_reached
    end
  end

  def check_boosting
    return unless crowd_boost_slot

    if boost_waitlist? && boost_waitlisted_at.present?
      return :boost_authorized unless crowd_boost_slot.amount_limit_reached?(self)
      return :boost_waitlist
    end

    return unless boost_approved?
    return unless crowd_pledges.initialized.count >= crowd_boost_slot.threshold_pledge_count
    return unless funding_percentage >= (crowd_boost_slot.threshold_funding_percentage || 0)

    return :boost_waitlist if crowd_boost_slot.amount_limit_reached?(self)

    :boost_authorized
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
    return nil unless startdate && enddate
  
    ((enddate - Date.current) + 1).to_i
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

  def set_visibility_and_newsletter
    attributes = case transaction_fee_percentage
                when 10.0..Float::INFINITY # Ab 10.0%
                  { visibility_status: "region", newsletter_status: "region", guest_newsletter: true, ending_newsletter: true }
                when 9.0...10.0 # Ab 9.0%
                  { visibility_status: "region", newsletter_status: "region", guest_newsletter: true, ending_newsletter: false }
                when 8.0...9.0 # Ab 8.0% 
                  { visibility_status: "region", newsletter_status: "graetzl", guest_newsletter: false, ending_newsletter: false }
                else # Unter 8.0%
                  { visibility_status: "graetzl", newsletter_status: "none", guest_newsletter: false, ending_newsletter: false }
                end
  
    update_columns(attributes)
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
    unless self.draft? || self.re_draft? || self.declined?
      throw :abort
    end
  end

  def set_transaction_fee
    self.service_fee_percentage = self.transaction_fee_percentage
    self.save
  end

  def send_draft_mail
    CrowdCampaignMailer.draft(self).deliver_later(wait: 15.minutes)
  end

end
