module GraetzlsHelper

  def district_url_options
    current_region.districts.sort_by(&:zip).map{|d| [d.zip_name, district_index_path(d)] }
  end

  def district_select_options
    current_region.districts.sort_by(&:zip).map{|d| [d.zip_name, d.id, 'data-label' => d.zip] }
  end

  def graetzl_url_options
    current_region.graetzls.sort_by(&:name).map{|g| ["#{g.name}", g.slug] }
  end

  def graetzl_select_options
    current_region.graetzls.sort_by(&:zip).map{|g| [g.zip_name, g.id, 'data-district-id' => g.district&.id] }
  end

  def compact_graetzl_list(graetzls)
    if current_region.use_districts?
      all_districts = current_region.districts.sort_by(&:zip)
      full_districts = all_districts.select{|d| (d.graetzl_ids - graetzls.map(&:id)).empty? }
      individual_graetzls = graetzls.select{|g| !full_districts.include?(g.district) }

      (full_districts.map(&:zip_name) + individual_graetzls.map(&:zip_name)).sort
    else
      graetzls.map(&:name).sort
    end
  end

  def graetzl_flag(graetzl)
    content_tag(:div, link_to(graetzl.name, [graetzl]), class: 'graetzl-sideflag sideflag -R')
  end

end
