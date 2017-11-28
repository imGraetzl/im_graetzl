module DistrictsHelper

  def district_url_options
    Rails.cache.fetch('district-url-options') do
      District.all.map { |d| [d.zip_name, district_path(d)] }
    end
  end

  def district_select_options
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
