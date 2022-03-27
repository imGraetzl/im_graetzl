class CrowdReward < ApplicationRecord
  belongs_to :crowd_campaign

  include AvatarUploader::Attachment(:avatar)

  #validates_presence_of :title

  def ready_for_submit?
    [title, amount, description].all?(&:present?)
  end

end
