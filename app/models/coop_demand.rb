class CoopDemand < ApplicationRecord
  include Trackable

  extend FriendlyId
  friendly_id :slogan

  belongs_to :user
  belongs_to :location, optional: true
  belongs_to :coop_demand_category

  has_many :coop_demand_graetzls
  has_many :graetzls, through: :coop_demand_graetzls
  has_many :districts, -> { distinct }, through: :graetzls
  has_many :comments, as: :commentable, dependent: :destroy

  enum coop_type: { demand: 0, offer: 1 }
  enum status: { enabled: 0, disabled: 1 }

  acts_as_taggable_on :keywords

  include AvatarUploader::Attachment(:avatar)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  scope :by_currentness, -> { order(last_activated_at: :desc) }
  scope :reactivated, -> { enabled.where("last_activated_at > created_at").where("created_at < ?", LIFETIME_MONTHS.months.ago) }

  LIFETIME_MONTHS = 6

  validates_presence_of :slogan, :demand_description, :personal_description, :avatar, :first_name, :last_name, :email, :coop_demand_category, :coop_type
  validate :has_one_graetzl_at_least

  def to_s
    slogan
  end

  def activation_code
    self.created_at.to_i
  end

  def activate
    self.status = :enabled
    self.last_activated_at = Time.now
  end

  def refresh_activity
    if enabled? && last_activated_at < 1.month.ago
      update(last_activated_at: Time.now)
    end
  end

  private

  def has_one_graetzl_at_least
    if graetzl_ids.empty?
      errors.add(:graetzls, "muss ausgewählt werden")
    end
  end
end
