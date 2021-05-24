class LocationCategory < ApplicationRecord
  has_many :locations
  include ImageUploader::Attachment(:main_photo)

end
