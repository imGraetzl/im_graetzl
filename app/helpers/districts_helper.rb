module DistrictsHelper

  def selectable_districts
    Rails.cache.fetch('selectable-districts') do
      District.all.pluck(:id, :name, :zip)
    end
  end

  def district_select_options
    Rails.cache.fetch('district-select-options') do
      options_for_select(District.all.map{|d| [d.zip_name, d.id, 'data-label' => d.zip]})
    end
  end

  def graetzl_select_options
    graetzl_options = District.includes(:graetzls).map do |district|
      district.graetzls.map{|g| ["#{district.zip} - #{g.name}", g.id, 'data-district-id' => district.id] }
    end.flatten(1)
    options_for_select(graetzl_options)
  end

end
