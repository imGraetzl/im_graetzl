class District < ActiveRecord::Base
  default_scope { order(zip: :asc) }

  extend FriendlyId
  friendly_id :long_name

  def graetzls
    Rails.cache.fetch(['graetzls', self], expires_in: 48.hours) do
      Graetzl.where('ST_INTERSECTS(area, :district)', district: self.area)
    end
  end

  def long_name
    "#{name}-#{zip}"
  end

  def numeric
    zip.slice(1..2).sub(%r{^0},"") if zip.present?
  end

  def locations
    Location.where(graetzl: graetzls)
  end

  def meetings
    Meeting.where(graetzl: graetzls)
  end

  def curators
    Curator.where(graetzl: graetzls)
  end

  def zuckerls
    Zuckerl.live.where(location_id:
      Location.select(:id).where(graetzl_id:
        Graetzl.select(:id).where('ST_INTERSECTS(area, ?)', self.area)))
  end
end
