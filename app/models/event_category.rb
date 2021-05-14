class EventCategory < ApplicationRecord
  has_and_belongs_to_many :meetings

  attachment :main_photo, type: :image
  include RefileShrineSynchronization

  def to_s
    title
  end

end
