class District < ActiveRecord::Base
  default_scope { order('zip ASC') }

  # instance methods
  def graetzls
    Graetzl.where('ST_OVERLAPS(area, :district)', district: self.area)
  end
end