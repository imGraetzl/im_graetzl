class CrowdBenefit < ApplicationRecord

  has_many :crowdfundings

  def to_s
    title
  end

end
