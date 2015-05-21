class District < ActiveRecord::Base
  extend FriendlyId
  friendly_id :long_name

  default_scope { order('zip ASC') }

  # instance methods
  def graetzls
    Graetzl.where('ST_OVERLAPS(area, :district)', district: self.area)
  end

  def long_name
    "#{name}-#{zip}"
  end
end