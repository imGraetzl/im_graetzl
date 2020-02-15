class MeetingAdditionalDate < ApplicationRecord
  belongs_to :meeting
  has_many :going_tos
  has_many :users, through: :going_tos

end
