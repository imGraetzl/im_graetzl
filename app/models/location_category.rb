class LocationCategory < ApplicationRecord
  enum context: { recreation: 0, business: 1 }
  has_many :locations
  include ImageUploader::Attachment(:main_photo)

end
