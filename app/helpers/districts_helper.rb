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

  def district_graetzl_select_options
    Rails.cache.fetch('district-graetzls-options') do
      districts = District.includes(:graetzls)
      option_groups_from_collection_for_select(districts, :graetzls, :zip_name, :id, :name)
    end
  end

end
