class District < ActiveRecord::Base

  # instance methods
  def graetzls
    Graetzl.where('ST_OVERLAPS(area, :district)', district: self.area)
  end
end