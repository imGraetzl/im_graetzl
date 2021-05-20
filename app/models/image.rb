class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true
  include ImageUploader::Attachment(:file)

end
