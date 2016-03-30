class AdminPost < Post
  has_many :operating_ranges, as: :operator
  has_many :graetzls, through: :operating_ranges
end
