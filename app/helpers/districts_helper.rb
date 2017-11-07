module DistrictsHelper

  def selectable_districts
    Rails.cache.fetch('selectable-districts') do
      District.all.pluck(:id, :name, :zip)
    end
  end

  def district_select_options(selected = nil)
    district_options = Rails.cache.fetch('district-select-options') do
      District.all.map{|d| [d.zip_name, d.id, 'data-label' => d.zip] }
    end

    options_for_select(district_options, selected)
  end

  def graetzl_select_options(selected = nil)
    graetzl_options = Rails.cache.fetch('graetzl-select-options') do
      District.includes(:graetzls).map do |district|
        district.graetzls.map{|g| ["#{district.zip} - #{g.name}", g.id, 'data-district-id' => district.id] }
      end.flatten(1)
    end

    options_for_select(graetzl_options, selected)
  end

end
