class CrowdDonation < ApplicationRecord
  belongs_to :crowdfunding
  enum donation_type: { material: 0, assistance: 1 }

  validates_presence_of :title
end
