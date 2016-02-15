class GoingTo < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :user
  belongs_to :meeting

  enum role: { attendee: 0, initiator: 1 }
end
