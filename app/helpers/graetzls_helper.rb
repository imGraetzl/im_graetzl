module GraetzlsHelper

  def compact_graetzl_list(graetzls)
    graetzl_ids = graetzls.includes(:districts).map{|g| [g.id, g]}.to_h

    whole_districts = []
    District.cached.each do |district|
      if Set.new(district.graetzl_ids).subset?(Set.new(graetzl_ids.keys))
        whole_districts << district
      end
    end

    whole_districts.each do |district|
      district.graetzl_ids.each { |gid| graetzl_ids.delete(gid) }
    end

    result = []
    result += whole_districts.map(&:zip_name)
    result += graetzl_ids.map{|_, g| "#{g.district.zip} - #{g.name}"}
    result.sort
  end

  def graetzl_flag(graetzl)
    content_tag(:div, link_to(graetzl.name, [graetzl]), class: 'graetzl-sideflag sideflag -R')
  end

end
