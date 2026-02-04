class CrowdReward < ApplicationRecord
  belongs_to :crowd_campaign
  has_many :crowd_pledges

  include AvatarUploader::Attachment(:avatar)

  enum :status, { enabled: 0, disabled: 1 }

  validates_presence_of :title, :amount

  scope :ordered_for_display, lambda {
    order(
      Arel.sql("CASE WHEN crowd_rewards.\"limit\" IS NOT NULL AND crowd_rewards.claimed >= crowd_rewards.\"limit\" THEN 1 ELSE 0 END ASC"),
      :amount
    )
  }

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
