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

  has_many :crowd_campaign_posts, dependent: :destroy
  has_many :comments, through: :crowd_campaign_posts
  has_many :comments, as: :commentable, dependent: :destroy

  enum status: { draft: 0, pending: 1, canceled: 2, approved: 3, funding: 4, completed: 5 }
  enum funding_status: { not_funded: 0, goal_1_reached: 1, goal_2_reached: 2 }
  enum billable: { no_bill: 0, bill: 1, donation_bill: 2 }

  include AvatarUploader::Attachment(:avatar)
  include CoverImageUploader::Attachment(:cover_photo)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :title, :graetzl

  scope :scope_public, -> { where(status: [:funding, :completed]) }
  scope :successful, -> { where(funding_status: [:goal_1_reached, :goal_2_reached]) }
  scope :by_currentness, -> { order(created_at: :desc) }

  def scope_public?
    funding? || completed?
  end

  def successful?
    goal_1_reached? || goal_2_reached?
  end

  def editable?
    draft? || pending? || approved? # Remove approved maybe?
  end

  def owned_by?(a_user)
    user_id.present? && user_id == a_user&.id
  end

  def actual_newest_post
    crowd_campaign_posts.select{|p| p.created_at > 4.weeks.ago}.last
  end

  def crowd_pledges_sum
    @cached_crowd_pledge_sum ||= self.crowd_pledges.complete.sum(:total_price)
  end

  def crowd_pledges_fee
    (crowd_pledges_sum / 100) * 4
  end

  def crowd_pledges_payout
    crowd_pledges_sum - crowd_pledges_fee
  end

  def check_funding
    if not_funded? && crowd_pledges_sum > funding_1_amount
      update(funding_status: 'goal_1_reached')
      return :goal_1_reached
    elsif funding_2_amount.present? && goal_1_reached? && crowd_pledges_sum > funding_2_amount
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
    (1..5).all?{|step| step_finished?(step)}
  end

  def step_finished?(step)
    case step
    when 1
      [title, slogan, crowd_category_ids, graetzl_id].all?(&:present?)
    when 2
      [startdate, enddate, description, support_description, about_description].all?(&:present?)
    when 3
      [funding_1_amount, funding_1_description].all?(&:present?)
    when 4
      crowd_rewards.present? && crowd_rewards.all?(&:ready_for_submit?)
    when 5
      [cover_photo_data].all?(&:present?)
    else
      false
    end
  end

  def remaining_days
    # Using + 1 because the last day counts too
    (self.enddate - Date.today + 1).to_i if self.enddate
  end

  def runtime
    "#{I18n.localize(self.startdate, format:'%d. %b %Y')} bis #{I18n.localize(self.enddate, format:'%d. %b %Y')}"
  end

  def to_s
    title
  end

  def graetzl=(value)
    super
    self.district ||= value.district if value.present?
  end

end
