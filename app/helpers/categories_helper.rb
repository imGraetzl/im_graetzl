module CategoriesHelper

  def special_categories
    ['kurzzeitmiete', 'online-shops', 'goodies', 'menus', 'balkon-solar']
  end

  def special_category_path(category)
    case category.title
    when 'Balkon-Solar'
      balkonsolar_path
    when 'Good Morning Dates'
      good_morning_dates_path
    when 'WeLocally Pop-Up'
      popup_path
    else
      region_meetings_path
    end
  end

  def location_category_icon(category)
    icon = category.icon || 'location'
    icon_tag(icon)
  end

end
