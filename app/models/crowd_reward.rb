class CrowdReward < ApplicationRecord
  belongs_to :crowd_campaign
  has_many :crowd_pledges

  include AvatarUploader::Attachment(:avatar)

  enum status: { enabled: 0, disabled: 1 }

  validates_presence_of :title, :amount

  def available?
    limit.nil? ? true : limit > claimed
  end

  def fully_claimed?
    !available?
  end

  def ready_for_submit?
    [title, amount, description].all?(&:present?)
  end

end
