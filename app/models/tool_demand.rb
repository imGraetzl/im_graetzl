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

  enum status: { enabled: 0, disabled: 1 }

  acts_as_taggable_on :keywords

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates_presence_of :slogan, :demand_description, :usage_description, :usage_days, :tool_category_id, :first_name, :last_name, :email
  validate :has_one_graetzl_at_least # doesn't work for some reason

  scope :by_currentness, -> { order(created_at: :desc) }

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

  def has_one_graetzl_at_least
    if graetzl_ids.empty?
      errors.add(:graetzls, "muss ausgewählt werden")
    end
  end

end