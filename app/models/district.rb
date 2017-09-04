class District < ApplicationRecord
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
    @locations ||= Location.where(graetzl: graetzls.map(&:id))
  end

  def meetings
    @meetings ||= Meeting.where(graetzl: graetzls.map(&:id))
  end

  def curators
    @curators ||= Curator.where(graetzl: graetzls.map(&:id))
  end

  def zuckerls
    @zuckerls ||= Zuckerl.live.where(location_id: locations.map(&:id))
  end
end
