module GraetzlsHelper

  def district_url_options
    @district_url_options ||= sorted_districts.map { |d| [d.zip_name, district_index_path(d)] }
  end

  def district_select_options
    @district_select_options ||= sorted_districts.map { |d| [d.zip_name, d.id, 'data-label' => d.zip] }
  end

  def graetzl_url_options
    @graetzl_url_options ||= current_region.graetzls.sort_by(&:name).map { |g| [g.name.to_s, g.slug] }
  end

  def graetzl_select_options
    @graetzl_select_options ||= begin
      graetzls = current_region.graetzls

      # Preload Districts - Immer eine Relation, außer explizit ein Array (dann Preloader nutzen)
      if current_region.use_districts?
        if graetzls.is_a?(Array)
          ActiveRecord::Associations::Preloader.new(records: graetzls, associations: :districts).call
        else
          graetzls = graetzls.includes(:districts)
        end
      end

      graetzls.to_a.sort_by(&:zip_name).map do |g|
        [g.zip_name, g.id, 'data-district-id' => g.district&.id]
      end
    end
  end

  def compact_graetzl_list(graetzls)
    if current_region.use_districts?
      all_districts = sorted_districts
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

  private

  def sorted_districts
    return [] unless current_region.use_districts?
    @sorted_districts ||= current_region.districts.sort_by(&:zip)
  end

end
