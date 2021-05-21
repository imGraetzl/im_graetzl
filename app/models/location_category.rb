class LocationCategory < ApplicationRecord
  has_many :locations

  attachment :main_photo, type: :image
  include RefileShrineSynchronization
  before_save { write_shrine_data(:main_photo) if main_photo_id_changed? }

end
