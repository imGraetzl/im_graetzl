class CrowdDonation < ApplicationRecord
  belongs_to :crowd_campaign
  enum donation_type: { material: 0, assistance: 1 }

  #validates_presence_of :title
end
