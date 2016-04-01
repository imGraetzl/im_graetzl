class Initiative < ActiveRecord::Base
  attachment :image, type: :image

  has_many :operating_ranges, as: :operator
  has_many :graetzls, through: :operating_ranges
  has_many :zuckerls
end
