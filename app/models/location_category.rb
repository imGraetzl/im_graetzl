class LocationCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :locations

  attachment :main_photo, type: :image
  include RefileShrineSynchronization
  before_save { write_shrine_data(:main_photo) if main_photo_id_changed? }

  def should_generate_new_friendly_id? #will change the slug if the name changed
    #name_changed?
  end

end
