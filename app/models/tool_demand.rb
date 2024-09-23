class ToolDemand < ApplicationRecord
  include Trackable
  extend FriendlyId
  friendly_id :slogan

  belongs_to :user
  belongs_to :location, optional: true
  belongs_to :tool_category, optional: true

  has_many :tool_demand_graetzls
  has_many :graetzls, through: :tool_demand_graetzls
  has_many :districts, -> { distinct }, through: :graetzls

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :favorites, as: :favoritable, dependent: :destroy

  enum status: { enabled: 0, disabled: 1 }

  acts_as_taggable_on :keywords

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  before_validation :smart_add_url_protocol, if: -> { website.present? }

  validates_presence_of :slogan, :demand_description, :usage_description, :usage_days, :tool_category_id, :first_name, :last_name, :email
  validate :has_one_graetzl_at_least # doesn't work for some reason
  validates :usage_period_from, presence: true, if: :usage_period?
  validates :usage_period_to, presence: true, if: :usage_period?

  scope :by_currentness, -> { order(created_at: :desc) }

  after_update :destroy_activity_and_notifications, if: -> { disabled? && saved_change_to_status? }

  def self.include_for_box
    includes(:user, :tool_category)
  end

  def to_s
    slogan
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def smart_add_url_protocol
    unless website[/\Ahttp:\/\//] || website[/\Ahttps:\/\//]
      self.website = "https://#{website}"
    end
  end

  def has_one_graetzl_at_least
    if graetzl_ids.empty?
      errors.add(:graetzls, "muss ausgewählt werden")
    end
  end

end
