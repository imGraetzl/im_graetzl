class CrowdCampaignPost < ApplicationRecord
  include Trackable

  belongs_to :graetzl
  belongs_to :crowd_campaign

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true

  before_validation :set_graetzl, on: :create

  def edit_permission?(user)
    user && crowd_campaign.owned_by?(user)
  end

  def region_id
    crowd_campaign.region_id
  end

  def user_id
    crowd_campaign.user_id
  end

  private

  def set_graetzl
    self.graetzl = crowd_campaign.graetzl
  end

end
