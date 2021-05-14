class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true
  attachment :file, type: :image
  include RefileShrineSynchronization

end
