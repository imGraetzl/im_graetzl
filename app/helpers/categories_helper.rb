module CategoriesHelper
  def category_icon(category)
    case category.name
    when 'Wohlbefinden & Gesundheit'
      use_svg 'leaf'
    when 'Geschäft / Ladenlokal im Grätzl'
      use_svg 'sale-label'
    when 'Kreativwirtschaft / Handwerk'
      use_svg 'painting-palette'
    when 'Lokaler Dienstleister'
      use_svg 'pin'
    when 'Unternehmen & Start-ups'
      use_svg 'mouse'
    when 'Gastronomie'
      use_svg 'tea-cup'
    when 'Öffentlicher Raum / Sozialer Treffpunkt'
      use_svg 'tree'
    else
      use_svg 'location'
    end
  end

  private

  def use_svg(klass)
    content_tag(:svg, content_tag(:use, nil, { 'xlink:href' => "#icon-#{klass}" }), class: "icon-#{klass}")
  end
end
