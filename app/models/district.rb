class District < ActiveRecord::Base  
  default_scope { order(zip: :asc) }

  extend FriendlyId
  friendly_id :long_name

  # instance methods
  def graetzls
    Graetzl.where('ST_INTERSECTS(area, :district)', district: self.area)
  end

  def long_name
    "#{name}-#{zip}"
  end
end