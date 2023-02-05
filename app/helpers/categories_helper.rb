module CategoriesHelper

  def special_categories
    ['kurzzeitmiete', 'online-shops', 'special-events', 'goodies', 'menus']
  end

  def special_category_path(category)
    case category.title
    when 'Balkon-Solar'
      balkonsolar_path
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
