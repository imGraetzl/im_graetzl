class RoomCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :room_offer_categories
  has_many :room_demand_categories

  attachment :main_photo, type: :image
  include RefileShrineSynchronization
  before_save { write_shrine_data(:main_photo) if main_photo_id_changed? }

  def to_s
    name
  end

  def should_generate_new_friendly_id? #will change the slug if the name changed
    slug.blank? || name_changed?
  end

end
