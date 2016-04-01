class AdminPost < Post
  # attr_accessor :all_graetzl, :district_ids
  # attr_accessor :district_ids

  has_many :operating_ranges, as: :operator
  has_many :graetzls, -> { uniq }, through: :operating_ranges

  # def district_ids
  #
  # end
  #
  # def district_ids=(values)
  #   values.reject!(&:empty?)
  #   unless values.empty?
  #     self.graetzls << Graetzl.where("ST_INTERSECTS(area,
  #       (SELECT ST_UNION(districts.area)
  #       FROM districts
  #       WHERE districts.id IN (?)))", values)
  #   end
  # end
end
