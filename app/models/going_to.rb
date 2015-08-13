class GoingTo < ActiveRecord::Base
  include PublicActivity::Common

  # associations
  belongs_to :user
  belongs_to :meeting
  has_many :activities, as: :trackable, class_name: 'PublicActivity::Activity', dependent: :destroy

  # validations
  validates :user, presence: true
  validates :meeting, presence: true

  enum role: { attendee: 0, initiator: 1 }

  def button_type
    
  end
end
