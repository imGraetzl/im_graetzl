class CrowdReward < ApplicationRecord
  belongs_to :crowd_campaign
  has_many :crowd_pledges

  include AvatarUploader::Attachment(:avatar)

  #validates_presence_of :title

  def available?
    if self.limit
      self.limit > self.crowd_pledges.complete.count
    else
      true
    end
  end

  def available_count
    self.limit - self.crowd_pledges.complete.count
  end

  def taken_count
    self.crowd_pledges.complete.count
  end

  def ready_for_submit?
    [title, amount, description].all?(&:present?)
  end

end
