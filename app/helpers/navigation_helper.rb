module NavigationHelper

  # Try Personal Logged-in Region Navigation Switch
  # Show in which Region the current User is logged-in (todo: cookie domain ...)
  def nav_region_menu_item(icon, label, url, region)
    if current_user && current_user.region_id == region.id
      user = avatar_image(current_user, size: :thumb, class: 'img-round avatar user-home')
      url = root_url(host: region.host)
    end
    link_to(url, class: 'nav-menu-item') do
      icon_tag(icon) + label + user
    end
  end

  def nav_menu_item(icon, label, url, options = {})
    options[:class] = [options[:class], 'nav-menu-item']
    link_to(url, options) do
      icon_tag(icon) + label
    end
  end

  def nav_submenu_link(icon, label, submenu, options = {})
    options[:class] = [options[:class], 'nav-menu-item']
    options[:data] = (options[:data] || {}).merge(submenu: submenu)
    badge = options.delete(:badge).to_i
    link_to('javascript:', options) do
      (badge > 0 ? icon_with_badge(icon, badge) : icon_tag(icon)) +
      label + content_tag(:span, icon_tag("arrow-right-2"), class: 'arrow')
    end
  end

  def nav_submenu_back(submenu, css = nil)
    link_to('javascript:', class: "#{css} nav-menu-item", data: {submenu: submenu}) do
      icon_tag("arrow-left-2") + 'Zurück'
    end
  end

  def nav_lazy_load_form(type)
    form_tag([:navigation, :load_content, type: type], remote: true, method: :get,
      id: "nav-load-#{type}", class: 'nav-load-form') do
    end
  end

end
