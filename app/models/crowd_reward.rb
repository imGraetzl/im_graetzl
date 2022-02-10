class CrowdReward < ApplicationRecord
  belongs_to :crowd_campaign

  include AvatarUploader::Attachment(:avatar)

  #validates_presence_of :title
end
