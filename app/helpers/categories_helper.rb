module CategoriesHelper

  def special_categories
    ['kurzzeitmiete', 'online-shops', 'goodies', 'menus', 'balkon-solar']
  end

  def special_category_path(category)
    case category.title
    when 'Good Morning Dates'
      good_morning_dates_path
    else
      region_meetings_path
    end
  end

  def location_category_icon(category)
    icon = category.icon || 'location'
    icon_tag(icon)
  end

end
