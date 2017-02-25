class AdminPost < Post
  has_many :operating_ranges, as: :operator
  has_many :graetzls, -> { distinct }, through: :operating_ranges

  attr_accessor :select_all_districts, :select_district
end
