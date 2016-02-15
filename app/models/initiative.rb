class Initiative < ActiveRecord::Base
  has_many :operating_ranges
  has_many :graetzls, through: :operating_ranges
  has_many :zuckerls
end
