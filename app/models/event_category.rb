class EventCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :title

  has_and_belongs_to_many :meetings

  attachment :main_photo, type: :image
  include RefileShrineSynchronization
  before_save { write_shrine_data(:main_photo) if main_photo_id_changed? }

  def to_s
    title
  end

end
