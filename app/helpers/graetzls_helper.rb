module GraetzlsHelper

  def district_url_options
    District.in(current_region).sorted_by_zip.map { |d| [d.zip_name, district_path(d)] }
  end

  def district_select_options
    District.in(current_region).sorted_by_zip.map { |d| [d.zip_name, d.id, 'data-label' => d.zip] }
  end

  def graetztl_url_options
    Graetzl.in(current_region).map { |g| ["#{g.name}", g.slug] }
  end

  def graetzl_select_options
    District.in(current_region).sorted_by_zip.map do |district|
      district.graetzls.map{|g| ["#{district.zip} - #{g.name}", g.id, 'data-district-id' => district.id] }
    end.flatten(1)
  end

  def compact_graetzl_list(graetzls)

    results = []

    if current_region.use_districts

      graetzl_ids = graetzls.map(&:id)
      cleaned_graetzl_ids = graetzl_ids

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

    else

      graetzls.each do |graetzl|
        results << graetzl.name
      end

    end

    results.sort
  end

  def graetzl_flag(graetzl)
    content_tag(:div, link_to(graetzl.name, [graetzl]), class: 'graetzl-sideflag sideflag -R')
  end

end
