module CategoriesHelper

  def special_categories
    ['kurzzeitmiete', 'online-shops', 'special-events', 'goodies', 'menus']
  end

  def location_category_icon(category)
    icon = category.icon || 'location'
    icon_tag(icon)
  end

end
