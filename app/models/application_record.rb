class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.in(region)
    where(region_id: region.id)
  end

  def region
    @region ||= Region.get(region_id)
  end

end
