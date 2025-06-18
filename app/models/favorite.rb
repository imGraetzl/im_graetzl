class Favorite < ApplicationRecord

  belongs_to :favoritable, polymorphic: true
  belongs_to :user, inverse_of: :favorites

  scope :coop_demands, -> { where(favoritable_type: 'CoopDemand') }
  scope :crowd_campaigns, -> { where(favoritable_type: 'CrowdCampaign') }
  scope :locations, -> { where(favoritable_type: 'Location') }
  scope :meetings, -> { where(favoritable_type: 'Meeting') }
  scope :room_demands, -> { where(favoritable_type: 'RoomDemand') }
  scope :room_offers, -> { where(favoritable_type: 'RoomOffer') }
  scope :users, -> { where(favoritable_type: 'User') }

  validates :user_id, uniqueness: {
    scope: [:favoritable_id, :favoritable_type],
    message: 'Ist bereits Favorite'
  }

  def target_url_params
    "favorite_#{favoritable.class.name.underscore}_#{favoritable.id}"
  end

  private

end
