module GraetzlsHelper

  def district_url_options
    District.sorted_by_zip.map { |d| [d.zip_name, district_path(d)] }
  end

  def district_select_options
    District.sorted_by_zip.map { |d| [d.zip_name, d.id, 'data-label' => d.zip] }
  end

  def graetzl_select_options
    District.sorted_by_zip.map do |district|
      district.graetzls.map{|g| ["#{district.zip} - #{g.name}", g.id, 'data-district-id' => district.id] }
    end.flatten(1)
  end

  def compact_graetzl_list(graetzls)
    graetzl_ids = graetzls.map(&:id)
    cleaned_graetzl_ids = graetzl_ids

    results = []
    District.sorted_by_zip.each do |district|
      if (district.graetzl_ids - graetzl_ids).empty?
        results << district.zip_name
        cleaned_graetzl_ids -= district.graetzl_ids
      end
    end

    cleaned_graetzl_ids.each do |graetzl_id|
      graetzl = Graetzl.memoized(graetzl_id)
      results << "#{graetzl.district.zip} - #{graetzl.name}"
    end

    results.sort
  end

  def graetzl_flag(graetzl)
    content_tag(:div, link_to(graetzl.name, [graetzl]), class: 'graetzl-sideflag sideflag -R')
  end

end
