class CrowdDonation < ApplicationRecord
  belongs_to :crowd_campaign
  has_many :crowd_donation_pledges

  enum donation_type: { material: 0, assistance: 1 , room: 2 }

  #validates_presence_of :title

  def available?
    if self.limit
      self.limit > self.crowd_donation_pledges.count
    else
      true
    end
  end

  def available_count
    self.limit - self.crowd_donation_pledges.count
  end

  def taken_count
    self.crowd_donation_pledges.count
  end

end
