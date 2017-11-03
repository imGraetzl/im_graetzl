class District < ApplicationRecord
  default_scope { order(zip: :asc) }

  extend FriendlyId
  friendly_id :long_name

  has_many :district_graetzls
  has_many :graetzls, through: :district_graetzls

  def long_name
    "#{name}-#{zip}"
  end

  def zip_name
    "#{zip} – #{name}"
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
