class CrowdCampaign < ApplicationRecord
  include Trackable
  include Address

  extend FriendlyId
  friendly_id :title

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

  enum status: { draft: 0, pending: 1, canceled: 2, approved: 3, funding: 4, completed_successful: 5, completed_unsuccessful: 6 }
  enum billable: { no_bill: 0, bill: 1, bill_with_tax: 2 }

  include CoverImageUploader::Attachment(:cover_photo)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :title, :graetzl

  scope :scope_public, -> { funding || completed_successful? || completed_unsuccessful? }
  scope :by_currentness, -> { order(created_at: :desc) }

  def scope_public?
    funding? || completed?
  end

  def completed?
    completed_successful? || completed_unsuccessful?
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

  def funding_status
    if !self.funding_1_amount.nil?
      if self.crowd_pledges_sum < self.funding_1_amount
        :funding_1
      elsif self.crowd_pledges_sum >= self.funding_1_amount && self.funding_2_amount.nil?
        :over_funding_1
      elsif self.crowd_pledges_sum < self.funding_2_amount
        :funding_2
      elsif self.crowd_pledges_sum >= self.funding_2_amount
        :over_funding_2
      end
    end
  end

  def funding_1?
    self.funding_status == :funding_1
  end

  def over_funding_1?
    self.funding_status == :over_funding_1
  end

  def funding_2?
    self.funding_status == :funding_2
  end

  def over_funding_2?
    self.funding_status == :over_funding_2
  end

  # Needed if we want to inform Owner for Successfull Funding_Level 1 immediately... (or other users)
  def funding_1_successful?(funding_status_before, funding_status_after)
    [:over_funding_1, :funding_2].include?(funding_status_after) && funding_status_before != funding_status_after
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
      crowd_rewards.present? && crowd_rewards.all?(:ready_for_submit?)
    when 5
      [cover_photo_data].all?(&:present?)
    else
      false
    end
  end

  def remaining_days
     (self.enddate - Date.today).to_i if self.enddate
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
