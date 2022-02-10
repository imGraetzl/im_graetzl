class CrowdReward < ApplicationRecord
  belongs_to :crowdfunding

  include AvatarUploader::Attachment(:avatar)

  #validates_presence_of :title
end
