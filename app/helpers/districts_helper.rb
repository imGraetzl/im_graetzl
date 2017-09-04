module DistrictsHelper

  def selectable_districts
    Rails.cache.fetch('selectable-districts') do
      District.all.pluck(:id, :name, :zip)
    end
  end

end
