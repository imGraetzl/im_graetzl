class GoingTo < ActiveRecord::Base
  include PublicActivity::Common

  # associations
  belongs_to :user
  belongs_to :meeting
  has_many :activities, as: :trackable, class_name: 'PublicActivity::Activity', dependent: :destroy

  # validations
  validates :user, presence: true
  validates :meeting, presence: true

  ROLES = { initiator: 0, attendee: 1 }
end
