class CrowdCampaign < ApplicationRecord
  include Trackable
  include Address

  extend FriendlyId
  friendly_id :title, :use => :history

  def should_generate_new_friendly_id?
    slug.blank? || title_changed? if self.draft?
  end

  belongs_to :user
  belongs_to :graetzl
  belongs_to :district, optional: true
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

  enum active_state: { enabled: 0, disabled: 1, deleted: 2 }
  enum status: { draft: 0, submit: 1, pending: 2, canceled: 3, approved: 4, funding: 5, completed: 6 }
  enum funding_status: { not_funded: 0, goal_1_reached: 1, goal_2_reached: 2 }
  enum billable: { no_bill: 0, bill: 1, donation_bill: 2 }

  include AvatarUploader::Attachment(:avatar)
  include CoverImageUploader::Attachment(:cover_photo)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :title, :graetzl
  validates_presence_of :title, :slogan, :crowd_category_ids, :graetzl_id, :startdate, :enddate, :description, :support_description, :aim_description, :about_description, :funding_1_amount, :funding_1_description, :cover_photo_data, :crowd_reward_ids, :contact_name, :contact_address, :contact_zip, :contact_city, :contact_email, :billable, if: :submit?

  scope :scope_public, -> { where(status: [:funding, :completed]).and(where(active_state: :enabled)) }
  scope :successful, -> { where(funding_status: [:goal_1_reached, :goal_2_reached]) }
  scope :by_currentness, -> { order(created_at: :desc) }

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
    draft? || submit? || pending?
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
    created_at.after?("2022-07-15".to_date) ? 5 : 4
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
      [title, slogan, crowd_category_ids, graetzl_id].all?(&:present?)
    when 2
      [startdate, enddate, description, support_description, aim_description, about_description].all?(&:present?)
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

  def graetzl=(value)
    super
    self.district ||= value.district if value.present?
  end

end
