module DistrictsHelper

  def selectable_districts
    Rails.cache.fetch('selectable-districts') do
      District.all.pluck(:id, :name, :zip)
    end
  end

  def district_select_options(deselect: false)
    deselect_option = deselect ? [deselect, 'deselect-all', 'data-label' => deselect] : []
    [deselect_option] +
    Rails.cache.fetch('district-select-options') do
      District.all.map{|d| [d.zip_name, d.id, 'data-label' => d.zip] }
    end
  end

  def graetzl_select_options
    Rails.cache.fetch('graetzl-select-options') do
      District.includes(:graetzls).map do |district|
        district.graetzls.map{|g| ["#{district.zip} - #{g.name}", g.id, 'data-district-id' => district.id] }
      end.flatten(1)
    end
  end

end
